using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.Models;
using ShopBackend.Models.Vnpay;
using ShopBackend.Services;
using ShopBackend.Services.Vnpay;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentController : ControllerBase
    {
        private readonly IVnPayService _vnPayService;
        private readonly NotificationService _notificationService;
        private readonly AppDbContext _db;

        public PaymentController(
            IVnPayService vnPayService,
            NotificationService notificationService,
            AppDbContext db)
        {
            _vnPayService = vnPayService;
            _notificationService = notificationService;
            _db = db;
        }

        // =====================================
        // 1. CREATE ORDER + ORDER ITEMS + PAYMENT
        // =====================================
        [HttpPost("create-vnpay-url")]
        public IActionResult CreatePaymentUrl([FromBody] PaymentInformationModel model)
        {
            if (model.Items == null || model.Items.Count == 0)
                return BadRequest("Đơn hàng không có sản phẩm");

            var variantIds = model.Items.Select(item => item.VariantId).Distinct().ToList();
            var unavailableVariantIds = _db.ProductVariants
                .Include(v => v.Product)
                .Where(v =>
                    variantIds.Contains(v.Id) &&
                    (v.Product == null || v.Product.IsDeleted))
                .Select(v => v.Id)
                .ToList();

            var variantsById = _db.ProductVariants
                .Where(v => variantIds.Contains(v.Id))
                .ToDictionary(v => v.Id);

            if (variantsById.Count != variantIds.Count || unavailableVariantIds.Any())
                return BadRequest("Một số sản phẩm trong giỏ hàng không còn khả dụng");

            var productAmount = model.Items?
                .Sum(item => item.Price * item.Quantity) ?? 0;
            var totalAmount = (decimal)model.Amount;
            var shippingFee = Math.Max(0m, totalAmount - productAmount);

            // =====================
            // 1. CREATE ORDER
            // =====================
            var order = new Order
            {
                OrderCode = $"ORD_{Guid.NewGuid().ToString("N")[..8].ToUpper()}",
                UserId = model.UserId,
                SubtotalPrice = productAmount,
                ShippingFee = shippingFee,
                TotalPrice = totalAmount,
                Status = "PENDING",
                ShippingName = model.Name,
                ShippingPhone = model.Phone,
                ShippingAddress = model.Address
            };

            _db.Orders.Add(order);
            _db.SaveChanges();

            // =====================
            // 2. INSERT ORDER ITEMS
            // =====================
            if (model.Items != null && model.Items.Count > 0)
            {
                foreach (var item in model.Items)
                {
                    _db.OrderItems.Add(new OrderItem
                    {
                        OrderId = order.Id,
                        ProductId = variantsById[item.VariantId].ProductId,
                        VariantId = item.VariantId,
                        ProductName = item.ProductName,
                        VariantName = item.VariantName,
                        Quantity = item.Quantity,
                        Price = item.Price
                    });
                }

                _db.SaveChanges();
            }

            // =====================
            // 3. CREATE PAYMENT
            // =====================
            var payment = new Payment
            {
                OrderId = order.Id,
                PaymentMethodId = 2, // VNPAY
                Amount = totalAmount,
                ProductAmount = productAmount,
                ShippingFee = shippingFee,
                TotalAmount = totalAmount,
                Status = "PENDING"
            };

            _db.Payments.Add(payment);
            _db.SaveChanges();

            // =====================
            // 4. BUILD VNPay MODEL
            // =====================
            model.OrderId = order.Id;
            model.OrderDescription = $"Order {order.OrderCode}";
            model.Name = order.OrderCode;

            var url = _vnPayService.CreatePaymentUrl(model, HttpContext);

            return Ok(new
            {
                orderId = order.Id,
                orderCode = order.OrderCode,
                paymentUrl = url
            });
        }

        // =====================================
        // 2. RETURN URL (UI ONLY - KHÔNG UPDATE DB)
        // =====================================
        [HttpGet("vnpay-return")]
        public IActionResult Return()
        {
            try
            {
                var response = _vnPayService.PaymentExecute(Request.Query);
                var result = ProcessVnPayPayment(response);

                return Redirect(result.Success
                    ? "https://shopapp.ddns.net/payment-success"
                    : "https://shopapp.ddns.net/payment-failed");
            }
            catch
            {
                return Redirect("https://shopapp.ddns.net/payment-failed");
            }
        }

        // =====================================
        // 3. IPN (SERVER TO SERVER - MAIN LOGIC)
        // =====================================
        [HttpGet("vnpay-ipn")]
        public IActionResult Ipn()
        {
            try
            {
                var response = _vnPayService.PaymentExecute(Request.Query);
                var result = ProcessVnPayPayment(response);

                return Ok(new { result.RspCode, result.Message });
            }
            catch
            {
                return Ok(new { RspCode = "99", Message = "Unknown error" });
            }
        }

        private (string RspCode, string Message, bool Success) ProcessVnPayPayment(
            PaymentResponseModel? response)
        {
            // =====================
            // 1. VALIDATE BASIC
            // =====================
            if (response == null || string.IsNullOrEmpty(response.OrderId))
                return ("01", "Invalid data", false);

            if (!long.TryParse(response.OrderId, out long orderId))
                return ("01", "Invalid order id", false);

            var payment = _db.Payments
                .FirstOrDefault(x => x.OrderId == orderId);

            if (payment == null)
                return ("01", "Payment not found", false);

            // =====================
            // 2. PREVENT DUPLICATE
            // =====================
            if (payment.Status == "SUCCESS")
                return ("02", "Already processed", true);

            // =====================
            // 3. CHECK AMOUNT (SECURITY)
            // =====================
            var amountFromVnpay = response.Amount / 100;

            if (payment.Amount != amountFromVnpay)
                return ("04", "Invalid amount", false);

            // =====================
            // 4. CHECK SUCCESS
            // =====================
            if (response.Success && response.VnPayResponseCode == "00")
            {
                // UPDATE PAYMENT
                payment.Status = "SUCCESS";
                payment.TransactionId = response.TransactionId;
                payment.VnpResponseCode = response.VnPayResponseCode;
                payment.BankCode = response.BankCode;
                payment.PaidAt = DateTime.Now;

                // UPDATE ORDER + PRODUCT SOLD/STOCK
                var order = _db.Orders.FirstOrDefault(x => x.Id == orderId);
                if (order != null)
                {
                    order.Status = "PAID";
                    order.UpdatedAt = DateTime.Now;
                    _notificationService.AddForUser(
                        order.UserId,
                        "Thanh toÃ¡n thÃ nh cÃ´ng",
                        $"ÄÆ¡n hÃ ng {order.OrderCode} Ä‘Ã£ thanh toÃ¡n thÃ nh cÃ´ng.",
                        "PAYMENT_SUCCESS");

                    var items = _db.OrderItems
                        .Where(x => x.OrderId == order.Id)
                        .ToList();

                    var orderedVariantIds = items.Select(x => x.VariantId).Distinct().ToList();
                    var variants = _db.ProductVariants
                        .Where(x => orderedVariantIds.Contains(x.Id))
                        .ToList();

                    var soldQuantitiesByProduct = new Dictionary<long, int>();

                    foreach (var item in items)
                    {
                        var variant = variants.FirstOrDefault(x => x.Id == item.VariantId);
                        if (variant == null)
                            continue;

                        variant.StockQuantity = Math.Max(0, variant.StockQuantity - item.Quantity);

                        if (soldQuantitiesByProduct.ContainsKey(variant.ProductId))
                        {
                            soldQuantitiesByProduct[variant.ProductId] += item.Quantity;
                        }
                        else
                        {
                            soldQuantitiesByProduct[variant.ProductId] = item.Quantity;
                        }
                    }

                    var soldProductIds = soldQuantitiesByProduct.Keys.ToList();
                    var products = _db.Products
                        .IgnoreQueryFilters()
                        .Where(x => soldProductIds.Contains(x.Id))
                        .ToList();

                    foreach (var product in products)
                    {
                        product.SoldCount += soldQuantitiesByProduct[product.Id];
                    }

                    var cart = _db.Carts.FirstOrDefault(x => x.UserId == order.UserId);
                    if (cart != null)
                    {
                        var orderedQuantitiesByVariant = items
                            .GroupBy(x => x.VariantId)
                            .ToDictionary(g => g.Key, g => g.Sum(x => x.Quantity));

                        orderedVariantIds = orderedQuantitiesByVariant.Keys.ToList();
                        var cartItems = _db.CartItems
                            .Where(x => x.CartId == cart.Id && orderedVariantIds.Contains(x.VariantId))
                            .ToList();

                        foreach (var cartItem in cartItems)
                        {
                            var orderedQuantity = orderedQuantitiesByVariant[cartItem.VariantId];
                            if (cartItem.Quantity > orderedQuantity)
                            {
                                cartItem.Quantity -= orderedQuantity;
                            }
                            else
                            {
                                _db.CartItems.Remove(cartItem);
                            }
                        }
                    }
                }

                _db.SaveChanges();

                return ("00", "Success", true);
            }

            // =====================
            // 5. FAILED
            // =====================
            payment.Status = "FAILED";

            var failedOrder = _db.Orders.FirstOrDefault(x => x.Id == orderId);
            if (failedOrder != null)
            {
                var shouldNotify = failedOrder.Status != "CANCEL";
                failedOrder.Status = "CANCEL";

                if (shouldNotify)
                {
                    _notificationService.AddForUser(
                        failedOrder.UserId,
                        "Thanh toÃ¡n tháº¥t báº¡i",
                        $"Thanh toÃ¡n cho Ä‘Æ¡n hÃ ng {failedOrder.OrderCode} khÃ´ng thÃ nh cÃ´ng.",
                        "PAYMENT_FAILED");
                }
            }

            _db.SaveChanges();

            return ("97", "Failed", false);
        }
    }
}
