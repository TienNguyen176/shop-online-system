using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.Models;

namespace ShopBackend.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/notifications")]
    public class NotificationsController : ControllerBase
    {
        private readonly AppDbContext _db;

        public NotificationsController(AppDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<IActionResult> GetNotifications()
        {
            var userId = CurrentUserId();
            if (userId == null) return Unauthorized();

            var notifications = await _db.Notifications
                .Where(x => x.UserId == userId.Value)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();

            return Ok(notifications.Select(ToDto));
        }

        [HttpPut("{id}/read")]
        public async Task<IActionResult> MarkAsRead(long id)
        {
            var userId = CurrentUserId();
            if (userId == null) return Unauthorized();

            var notification = await _db.Notifications
                .FirstOrDefaultAsync(x => x.Id == id && x.UserId == userId.Value);

            if (notification == null) return NotFound();

            notification.IsRead = true;
            await _db.SaveChangesAsync();

            return Ok(ToDto(notification));
        }

        [HttpPut("read-all")]
        public async Task<IActionResult> MarkAllAsRead()
        {
            var userId = CurrentUserId();
            if (userId == null) return Unauthorized();

            var notifications = await _db.Notifications
                .Where(x => x.UserId == userId.Value && !x.IsRead)
                .ToListAsync();

            foreach (var notification in notifications)
            {
                notification.IsRead = true;
            }

            await _db.SaveChangesAsync();

            return Ok(new { message = "Marked as read" });
        }

        private long? CurrentUserId()
        {
            var value = User.FindFirst("id")?.Value;
            return long.TryParse(value, out var userId) ? userId : null;
        }

        private static object ToDto(Notification notification)
        {
            return new
            {
                notification.Id,
                notification.UserId,
                notification.Title,
                notification.Message,
                notification.Type,
                IsRead = notification.IsRead,
                notification.CreatedAt
            };
        }
    }
}
