using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.Models;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/admin/orders")]
    public class OrdersAdminController : ControllerBase
    {
        private readonly AppDbContext _db;

        public OrdersAdminController(AppDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<IActionResult> GetOrders(string? status = null)
        {
            var query = _db.Orders.AsQueryable();

            if (!string.IsNullOrWhiteSpace(status))
            {
                var normalizedStatus = status.Trim().ToUpper();
                query = query.Where(x => x.Status == normalizedStatus);
            }

            var orders = await query
                .OrderByDescending(x => x.CreatedAt)
                .Select(x => new
                {
                    x.Id,
                    x.OrderCode,
                    x.UserId,
                    x.Status,
                    x.SubtotalPrice,
                    x.ShippingFee,
                    x.TotalPrice,
                    x.ShippingName,
                    x.ShippingPhone,
                    x.ShippingAddress,
                    x.CreatedAt,
                    x.UpdatedAt,
                    x.DeliveredAt
                })
                .ToListAsync();

            return Ok(orders);
        }

        [HttpPut("{orderId}/status")]
        public async Task<IActionResult> UpdateStatus(
            long orderId,
            [FromBody] UpdateOrderStatusRequest request)
        {
            var order = await _db.Orders.FirstOrDefaultAsync(x => x.Id == orderId);
            if (order == null) return NotFound(new { message = "Order not found" });

            var currentStatus = order.Status.ToUpper();
            var nextStatus = request.Status.Trim().ToUpper();
            var now = DateTime.Now;

            if (nextStatus == currentStatus)
                return Ok(ToDto(order));

            if (currentStatus == "PENDING" && nextStatus == "PAID")
            {
                order.Status = "PAID";
                order.UpdatedAt = now;
            }
            else if (currentStatus == "PAID" && nextStatus == "DELIVERED")
            {
                order.Status = "DELIVERED";
                order.UpdatedAt = now;
                order.DeliveredAt = now;
            }
            else
            {
                return BadRequest(new
                {
                    message = "Invalid status transition. Only PENDING -> PAID -> DELIVERED is allowed."
                });
            }

            await _db.SaveChangesAsync();
            return Ok(ToDto(order));
        }

        [HttpGet("return-requests")]
        public async Task<IActionResult> GetReturnRequests(string? status = null)
        {
            var query = _db.ReturnRequests
                .Include(x => x.Order)
                .AsQueryable();

            if (!string.IsNullOrWhiteSpace(status))
            {
                var normalizedStatus = status.Trim().ToUpper();
                query = query.Where(x => x.Status == normalizedStatus);
            }

            var requests = await query
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();

            return Ok(requests.Select(ToReturnDto));
        }

        [HttpPut("return-requests/{requestId}/status")]
        public async Task<IActionResult> UpdateReturnRequestStatus(
            long requestId,
            [FromBody] UpdateReturnRequestStatus request)
        {
            var returnRequest = await _db.ReturnRequests
                .Include(x => x.Order)
                .FirstOrDefaultAsync(x => x.Id == requestId);

            if (returnRequest == null)
                return NotFound(new { message = "Return request not found" });

            var currentStatus = returnRequest.Status?.ToUpper() ?? "";
            var nextStatus = request.Status.Trim().ToUpper();

            if (currentStatus != "PENDING")
                return BadRequest(new { message = "Return request already reviewed" });

            if (nextStatus != "APPROVED" && nextStatus != "REJECTED")
                return BadRequest(new { message = "Only APPROVED or REJECTED is allowed" });

            returnRequest.Status = nextStatus;

            await _db.SaveChangesAsync();
            return Ok(ToReturnDto(returnRequest));
        }

        private static object ToDto(Models.Order order)
        {
            return new
            {
                order.Id,
                order.OrderCode,
                order.UserId,
                order.Status,
                order.SubtotalPrice,
                order.ShippingFee,
                order.TotalPrice,
                order.ShippingName,
                order.ShippingPhone,
                order.ShippingAddress,
                order.CreatedAt,
                order.UpdatedAt,
                order.DeliveredAt
            };
        }

        private static object ToReturnDto(ReturnRequest request)
        {
            var order = request.Order;

            return new
            {
                request.Id,
                request.OrderId,
                request.UserId,
                request.Reason,
                request.Status,
                request.CreatedAt,
                OrderCode = order?.OrderCode ?? "",
                OrderStatus = order?.Status ?? "",
                TotalPrice = order?.TotalPrice ?? 0,
                ShippingName = order?.ShippingName ?? "",
                ShippingPhone = order?.ShippingPhone ?? "",
                ShippingAddress = order?.ShippingAddress ?? "",
                DeliveredAt = order?.DeliveredAt
            };
        }
    }

    public class UpdateOrderStatusRequest
    {
        public string Status { get; set; } = "";
    }

    public class UpdateReturnRequestStatus
    {
        public string Status { get; set; } = "";
    }
}
