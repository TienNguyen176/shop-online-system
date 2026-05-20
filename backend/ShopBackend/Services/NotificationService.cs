using ShopBackend.Data;
using ShopBackend.Models;

namespace ShopBackend.Services
{
    public class NotificationService
    {
        private readonly AppDbContext _db;

        public NotificationService(AppDbContext db)
        {
            _db = db;
        }

        public void AddForUser(long? userId, string title, string message, string type)
        {
            if (!userId.HasValue) return;

            _db.Notifications.Add(new Notification
            {
                UserId = userId.Value,
                Title = title,
                Message = message,
                Type = type,
                IsRead = false,
                CreatedAt = DateTime.Now
            });
        }
    }
}
