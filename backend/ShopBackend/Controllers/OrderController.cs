using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
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

        // lấy tất cả đơn theo user
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
                    message = "Không có đơn hàng"
                });
            }

            return Ok(orders);
        }

        // lấy đơn theo trạng thái
        [HttpGet("user/{userId}/status/{status}")]
        public async Task<IActionResult> GetOrdersByStatus(
            long userId,
            string status)
        {
            var normalizedStatus = status.ToUpper();

            var orders = await _context.Orders
                .Where(o => o.UserId == userId &&
                            o.Status == normalizedStatus)
                .OrderByDescending(o => o.CreatedAt)
                .ToListAsync();

            return Ok(orders);
        }
    }
}
