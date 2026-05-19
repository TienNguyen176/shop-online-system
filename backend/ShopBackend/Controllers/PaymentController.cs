using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.Models;
using ShopBackend.Models.Vnpay;
using ShopBackend.Services.Vnpay;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PaymentController : ControllerBase
    {
        private readonly IVnPayService _vnPayService;
        private readonly AppDbContext _db;

        public PaymentController(IVnPayService vnPayService, AppDbContext db)
        {
            _vnPayService = vnPayService;
            _db = db;
        }

        // =====================================
        // 1. CREATE ORDER + ORDER ITEMS + PAYMENT
        // =====================================
        [HttpPost("create-vnpay-url")]
        public IActionResult CreatePaymentUrl([FromBody] PaymentInformationModel model)
        {
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
                        ProductId = item.ProductId,
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
            var response = _vnPayService.PaymentExecute(Request.Query);

            if (response == null)
            {
                return Redirect("https://shopapp.ddns.net/payment-failed");
            }

            if (response.VnPayResponseCode == "00")
            {
                return Redirect("https://shopapp.ddns.net/payment-success");
            }

            return Redirect("https://shopapp.ddns.net/payment-failed");
        }

        // =====================================
        // 3. IPN (SERVER TO SERVER - MAIN LOGIC)
        // =====================================
        [HttpGet("vnpay-ipn")]
        public IActionResult Ipn()
        {
            var response = _vnPayService.PaymentExecute(Request.Query);

            // =====================
            // 1. VALIDATE BASIC
            // =====================
            if (response == null || string.IsNullOrEmpty(response.OrderId))
                return Ok(new { RspCode = "01", Message = "Invalid data" });

            if (!long.TryParse(response.OrderId, out long orderId))
                return Ok(new { RspCode = "01", Message = "Invalid order id" });

            var payment = _db.Payments
                .FirstOrDefault(x => x.OrderId == orderId);

            if (payment == null)
                return Ok(new { RspCode = "01", Message = "Payment not found" });

            // =====================
            // 2. PREVENT DUPLICATE
            // =====================
            if (payment.Status == "SUCCESS")
                return Ok(new { RspCode = "02", Message = "Already processed" });

            // =====================
            // 3. CHECK AMOUNT (SECURITY)
            // =====================
            var amountFromVnpay = response.Amount / 100;

            if (payment.Amount != amountFromVnpay)
                return Ok(new { RspCode = "04", Message = "Invalid amount" });

            // =====================
            // 4. CHECK SUCCESS
            // =====================
            if (response.Success && response.VnPayResponseCode == "00")
            {
                // UPDATE PAYMENT
                payment.Status = "SUCCESS";
                payment.TransactionId = response.TransactionId;
                payment.VnpResponseCode = response.VnPayResponseCode;
                payment.PaidAt = DateTime.Now;

                // UPDATE ORDER + PRODUCT SOLD/STOCK
                var order = _db.Orders.FirstOrDefault(x => x.Id == orderId);
                if (order != null)
                {
                    order.Status = "PAID";

                    var items = _db.OrderItems
                        .Where(x => x.OrderId == order.Id)
                        .ToList();

                    foreach (var item in items)
                    {
                        var product = _db.Products.FirstOrDefault(x => x.Id == item.ProductId);
                        if (product != null)
                        {
                            product.SoldCount += item.Quantity;
                        }

                        var variant = _db.ProductVariants.FirstOrDefault(x => x.Id == item.VariantId);
                        if (variant != null)
                        {
                            variant.StockQuantity = Math.Max(0, variant.StockQuantity - item.Quantity);
                        }
                    }
                }

                _db.SaveChanges();

                return Ok(new { RspCode = "00", Message = "Success" });
            }

            // =====================
            // 5. FAILED
            // =====================
            payment.Status = "FAILED";
            _db.SaveChanges();

            return Ok(new { RspCode = "97", Message = "Failed" });
        }
    }
}
