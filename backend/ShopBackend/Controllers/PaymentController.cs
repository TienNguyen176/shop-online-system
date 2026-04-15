using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.DTOs;
using ShopBackend.Models;
using ShopBackend.Services.Payment;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/payment")]
    public class PaymentController : ControllerBase
    {
        private readonly AppDbContext _db;
        private readonly PaymentFactory _factory;

        public PaymentController(AppDbContext db, PaymentFactory factory)
        {
            _db = db;
            _factory = factory;
        }

        [HttpPost("checkout")]
        public IActionResult Checkout(CheckoutRequest req)
        {
            using var transaction = _db.Database.BeginTransaction();

            try
            {
                // =====================
                // 1. VALIDATE PAYMENT METHOD
                // =====================
                var paymentMethod = _db.PaymentMethods
                    .FirstOrDefault(x => x.Id == req.PaymentMethodId);

                if (paymentMethod == null)
                    return BadRequest("Invalid payment method");

                // =====================
                // 2. CREATE ORDER
                // =====================
                var order = new Order
                {
                    UserId = req.UserId,
                    TotalPrice = req.TotalPrice,
                    ShippingName = req.ShippingName,
                    ShippingPhone = req.ShippingPhone,
                    ShippingAddress = req.ShippingAddress,
                    Status = "PENDING",
                    CreatedAt = DateTime.UtcNow
                };

                _db.Orders.Add(order);
                _db.SaveChanges();

                // =====================
                // 3. ORDER ITEMS
                // =====================
                foreach (var item in req.Items)
                {
                    _db.OrderItems.Add(new OrderItem
                    {
                        OrderId = order.Id,
                        ProductId = item.ProductId,
                        VariantId = item.VariantId,
                        Quantity = item.Quantity,
                        Price = item.Price
                    });
                }

                // =====================
                // 4. PAYMENT RECORD
                // =====================
                var payment = new Payment
                {
                    OrderId = order.Id,
                    PaymentMethodId = req.PaymentMethodId,
                    Amount = req.TotalPrice,
                    Status = "PENDING",
                    TransactionId = order.OrderCode,
                    CreatedAt = DateTime.UtcNow
                };

                _db.Payments.Add(payment);

                // SAVE ALL (ORDER ITEMS + PAYMENT)
                _db.SaveChanges();

                // =====================
                // 5. COMMIT TRANSACTION
                // =====================
                transaction.Commit();

                // =====================
                // 6. CREATE PAYMENT URL
                // =====================
                var ip = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";

                var url = _factory.Create(order, req.PaymentMethodId, ip);

                return Ok(new PaymentResponse
                {
                    OrderId = order.Id,
                    PaymentUrl = url
                });
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        // =========================
        // VNPay RETURN (SAFE)
        // =========================
        [HttpGet("vnpay-return")]
        public IActionResult VnpayReturn()
        {
            var orderCode = Request.Query["vnp_TxnRef"].ToString();

            var order = _db.Orders
                .FirstOrDefault(x => x.OrderCode == orderCode);

            if (order == null)
                return BadRequest("Order not found");

            if (order.Status == "PAID")
                return Ok("Already processed");

            order.Status = "PAID";

            _db.SaveChanges();

            return Redirect("myapp://payment-success");
        }

        // =========================
        // MoMo IPN (stub)
        // =========================
        [HttpPost("momo-ipn")]
        public IActionResult MoMoIpn()
        {
            // TODO:
            // 1. verify signature
            // 2. check amount
            // 3. update order status

            return Ok();
        }
    }
}