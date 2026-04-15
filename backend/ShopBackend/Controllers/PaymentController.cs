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
        private readonly VNPayService _vnpay;

        public PaymentController(AppDbContext db, VNPayService vnpay)
        {
            _db = db;
            _vnpay = vnpay;
        }

        [HttpPost("checkout")]
        public IActionResult Checkout(CheckoutRequest req)
        {
            using var tx = _db.Database.BeginTransaction();

            var order = new Order
            {
                UserId = req.UserId,
                TotalPrice = req.TotalPrice,
                OrderCode = "ORD_" + DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
                Status = "PENDING",
                CreatedAt = DateTime.UtcNow
            };

            _db.Orders.Add(order);
            _db.SaveChanges();

            foreach (var i in req.Items)
            {
                _db.OrderItems.Add(new OrderItem
                {
                    OrderId = order.Id,
                    ProductId = i.ProductId,
                    VariantId = i.VariantId,
                    Quantity = i.Quantity,
                    Price = i.Price
                });
            }

            _db.SaveChanges();
            tx.Commit();

            var ip = HttpContext.Connection.RemoteIpAddress?.ToString();

            var url = _vnpay.CreatePaymentUrl(order, ip);

            return Ok(new
            {
                order.Id,
                paymentUrl = url
            });
        }

        [HttpGet("vnpay-return")]
        public IActionResult Return()
        {
            if (!_vnpay.ValidateReturn(Request.Query))
                return BadRequest("Invalid signature");

            var orderCode = Request.Query["vnp_TxnRef"].ToString();
            var responseCode = Request.Query["vnp_ResponseCode"].ToString();

            var order = _db.Orders.FirstOrDefault(x => x.OrderCode == orderCode);
            if (order == null) return BadRequest("Not found");

            order.Status = responseCode == "00" ? "PAID" : "FAILED";

            _db.SaveChanges();

            return Redirect("myapp://payment-success");
        }

        [HttpGet("vnpay-ipn")]
        public IActionResult Ipn()
        {
            var vnpData = Request.Query.ToDictionary(x => x.Key, x => x.Value.ToString());

            // =========================
            // 1. VERIFY SIGNATURE
            // =========================
            if (!_vnpay.ValidateReturn(Request.Query))
            {
                return Ok(new
                {
                    RspCode = "97",
                    Message = "Invalid signature"
                });
            }

            // =========================
            // 2. GET ORDER
            // =========================
            var orderCode = vnpData["vnp_TxnRef"];

            var order = _db.Orders.FirstOrDefault(x => x.OrderCode == orderCode);

            if (order == null)
            {
                return Ok(new
                {
                    RspCode = "01",
                    Message = "Order not found"
                });
            }

            // =========================
            // 3. CHECK AMOUNT (IMPORTANT)
            // =========================
            var vnpAmount = long.Parse(vnpData["vnp_Amount"]);
            var expectedAmount = (long)(order.TotalPrice * 100);

            if (vnpAmount != expectedAmount)
            {
                return Ok(new
                {
                    RspCode = "04",
                    Message = "Invalid amount"
                });
            }

            // =========================
            // 4. UPDATE ORDER STATUS
            // =========================
            var responseCode = vnpData["vnp_ResponseCode"];

            if (responseCode == "00")
                order.Status = "PAID";
            else
                order.Status = "FAILED";

            _db.SaveChanges();

            // =========================
            // 5. RETURN SUCCESS TO VNPay
            // =========================
            return Ok(new
            {
                RspCode = "00",
                Message = "Confirm Success"
            });
        }
    }
}