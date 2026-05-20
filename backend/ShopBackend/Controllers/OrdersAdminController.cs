using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.Models;
using ShopBackend.Services;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/admin/orders")]
    public class OrdersAdminController : ControllerBase
    {
        private readonly AppDbContext _db;
        private readonly NotificationService _notificationService;

        public OrdersAdminController(AppDbContext db, NotificationService notificationService)
        {
            _db = db;
            _notificationService = notificationService;
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
                _notificationService.AddForUser(
                    order.UserId,
                    "ÄÆ¡n hÃ ng Ä‘Ã£ Ä‘Æ°á»£c duyá»‡t",
                    $"ÄÆ¡n hÃ ng {order.OrderCode} Ä‘Ã£ Ä‘Æ°á»£c duyá»‡t vÃ  chuyá»ƒn sang chá» giao hÃ ng.",
                    "ORDER_PAID");
            }
            else if (currentStatus == "PAID" && nextStatus == "DELIVERED")
            {
                order.Status = "DELIVERED";
                order.UpdatedAt = now;
                order.DeliveredAt = now;
                _notificationService.AddForUser(
                    order.UserId,
                    "ÄÆ¡n hÃ ng Ä‘Ã£ giao",
                    $"ÄÆ¡n hÃ ng {order.OrderCode} Ä‘Ã£ Ä‘Æ°á»£c xÃ¡c nháº­n giao thÃ nh cÃ´ng.",
                    "ORDER_DELIVERED");
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

            var orderCode = returnRequest.Order?.OrderCode ?? $"#{returnRequest.OrderId}";
            _notificationService.AddForUser(
                returnRequest.UserId,
                nextStatus == "APPROVED"
                    ? "YÃªu cáº§u hoÃ n tiá»n Ä‘Ã£ Ä‘Æ°á»£c duyá»‡t"
                    : "YÃªu cáº§u hoÃ n tiá»n bá»‹ tá»« chá»‘i",
                nextStatus == "APPROVED"
                    ? $"YÃªu cáº§u tráº£ hÃ ng/hoÃ n tiá»n cho Ä‘Æ¡n {orderCode} Ä‘Ã£ Ä‘Æ°á»£c duyá»‡t."
                    : $"YÃªu cáº§u tráº£ hÃ ng/hoÃ n tiá»n cho Ä‘Æ¡n {orderCode} Ä‘Ã£ bá»‹ tá»« chá»‘i.",
                nextStatus == "APPROVED" ? "RETURN_APPROVED" : "RETURN_REJECTED");

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
