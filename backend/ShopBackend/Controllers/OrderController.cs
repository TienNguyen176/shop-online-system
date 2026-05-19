using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.DTOs;
using ShopBackend.Models;

namespace ShopBackend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OrderController : ControllerBase
    {
        private readonly AppDbContext _context;

        public OrderController(AppDbContext context)
        {
            _context = context;
        }

        [Authorize]
        [HttpGet("{orderId}")]
        public async Task<IActionResult> GetOrderDetail(long orderId)
        {
            var userId = CurrentUserId();
            if (userId == null) return Unauthorized();

            var order = await _context.Orders.FirstOrDefaultAsync(o => o.Id == orderId);
            if (order == null) return NotFound();
            if (order.UserId != userId.Value) return Forbid();

            return Ok(await ToDetail(order));
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetOrdersByUser(long userId)
        {
            var orders = await _context.Orders
                .Where(o => o.UserId == userId)
                .OrderByDescending(o => o.CreatedAt)
                .ToListAsync();

            if (!orders.Any())
            {
                return NotFound(new
                {
                    message = "Khong co don hang"
                });
            }

            return Ok(orders);
        }

        [HttpGet("user/{userId}/status/{status}")]
        public async Task<IActionResult> GetOrdersByStatus(long userId, string status)
        {
            var normalizedStatus = status.ToUpper();

            var orders = await _context.Orders
                .Where(o => o.UserId == userId && o.Status == normalizedStatus)
                .OrderByDescending(o => o.CreatedAt)
                .ToListAsync();

            return Ok(orders);
        }

        [Authorize]
        [HttpPut("{orderId}/shipping-address")]
        public async Task<IActionResult> UpdateShippingAddress(
            long orderId,
            [FromBody] UpsertUserAddressRequest request)
        {
            var userId = CurrentUserId();
            if (userId == null) return Unauthorized();

            var order = await _context.Orders.FirstOrDefaultAsync(o => o.Id == orderId);
            if (order == null) return NotFound();
            if (order.UserId != userId.Value) return Forbid();

            if (order.Status != "PENDING")
            {
                return BadRequest(new { message = "Chi co the doi dia chi don cho xac nhan" });
            }

            var parts = new[]
            {
                request.AddressLine,
                request.WardName,
                request.DistrictName,
                request.ProvinceName
            }.Where(x => !string.IsNullOrWhiteSpace(x));

            order.ShippingName = request.ReceiverName.Trim();
            order.ShippingPhone = request.Phone.Trim();
            order.ShippingAddress = string.Join(", ", parts);

            await _context.SaveChangesAsync();
            return Ok(await ToDetail(order));
        }

        [Authorize]
        [HttpDelete("{orderId}")]
        public async Task<IActionResult> DeleteOrder(long orderId)
        {
            var userId = CurrentUserId();
            if (userId == null) return Unauthorized();

            var order = await _context.Orders.FirstOrDefaultAsync(o => o.Id == orderId);
            if (order == null) return NotFound();
            if (order.UserId != userId.Value) return Forbid();

            if (order.Status != "PENDING")
            {
                return BadRequest(new { message = "Chi co the huy don cho xac nhan" });
            }

            order.Status = "CANCEL";
            order.UpdatedAt = DateTime.Now;
            await _context.SaveChangesAsync();

            return Ok(new { message = "Cancelled" });
        }

        [Authorize]
        [HttpPost("{orderId}/return-request")]
        public async Task<IActionResult> CreateReturnRequest(
            long orderId,
            [FromBody] CreateReturnRequest request)
        {
            var userId = CurrentUserId();
            if (userId == null) return Unauthorized();

            var order = await _context.Orders.FirstOrDefaultAsync(o => o.Id == orderId);
            if (order == null) return NotFound();
            if (order.UserId != userId.Value) return Forbid();

            if (order.Status != "DELIVERED" || order.DeliveredAt == null)
            {
                return BadRequest(new { message = "Chi co the yeu cau tra hang voi don da giao" });
            }

            if (DateTime.Now > order.DeliveredAt.Value.AddDays(7))
            {
                return BadRequest(new { message = "Da qua han 7 ngay de tra hang hoan tien" });
            }

            var hasOpenRequest = await _context.ReturnRequests.AnyAsync(x =>
                x.OrderId == order.Id &&
                x.UserId == userId.Value &&
                x.Status != "REJECTED");

            if (hasOpenRequest)
            {
                return BadRequest(new { message = "Don hang da co yeu cau tra hang hoan tien" });
            }

            var returnRequest = new ReturnRequest
            {
                OrderId = order.Id,
                UserId = userId.Value,
                Reason = request.Reason?.Trim(),
                Status = "PENDING",
                CreatedAt = DateTime.Now
            };

            _context.ReturnRequests.Add(returnRequest);
            await _context.SaveChangesAsync();

            return Ok(ToReturnDto(returnRequest));
        }

        private long? CurrentUserId()
        {
            var value = User.FindFirst("id")?.Value;
            return long.TryParse(value, out var userId) ? userId : null;
        }

        private async Task<object> ToDetail(Order order)
        {
            var items = await _context.OrderItems
                .Where(x => x.OrderId == order.Id)
                .ToListAsync();

            var variantIds = items.Select(x => x.VariantId).Distinct().ToList();
            var productIds = items
                .Where(x => x.ProductId > 0)
                .Select(x => x.ProductId)
                .Distinct()
                .ToList();

            var variants = await _context.ProductVariants
                .Where(x => variantIds.Contains(x.Id))
                .ToListAsync();

            productIds.AddRange(variants.Select(x => x.ProductId));
            productIds = productIds.Distinct().ToList();

            var images = await _context.ProductImages
                .Where(x => productIds.Contains(x.ProductId))
                .OrderByDescending(x => x.IsMain)
                .ThenBy(x => x.Id)
                .ToListAsync();

            var returnRequest = await _context.ReturnRequests
                .Where(x => x.OrderId == order.Id && x.UserId == order.UserId)
                .OrderByDescending(x => x.CreatedAt)
                .FirstOrDefaultAsync();

            return new
            {
                order.Id,
                order.OrderCode,
                order.Status,
                order.SubtotalPrice,
                order.ShippingFee,
                order.TotalPrice,
                order.ShippingName,
                order.ShippingPhone,
                order.ShippingAddress,
                order.CreatedAt,
                order.UpdatedAt,
                order.DeliveredAt,
                ReturnRequest = returnRequest == null ? null : ToReturnDto(returnRequest),
                items = items.Select(item =>
                {
                    var productId = item.ProductId > 0
                        ? item.ProductId
                        : variants.FirstOrDefault(x => x.Id == item.VariantId)?.ProductId ?? 0;

                    return new
                    {
                        ProductId = productId,
                        item.VariantId,
                        item.ProductName,
                        item.VariantName,
                        item.Quantity,
                        item.Price,
                        image = images.FirstOrDefault(x => x.ProductId == productId && x.VariantId == item.VariantId)?.ImageUrl
                            ?? images.FirstOrDefault(x => x.ProductId == productId && x.IsMain)?.ImageUrl
                            ?? images.FirstOrDefault(x => x.ProductId == productId)?.ImageUrl
                            ?? ""
                    };
                })
            };
        }

        private static object ToReturnDto(ReturnRequest request)
        {
            return new
            {
                request.Id,
                request.OrderId,
                request.UserId,
                request.Reason,
                request.Status,
                request.CreatedAt
            };
        }
    }

    public class CreateReturnRequest
    {
        public string? Reason { get; set; }
    }
}
