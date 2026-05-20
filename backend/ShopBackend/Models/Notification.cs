using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    [Table("notifications")]
    public class Notification
    {
        public long Id { get; set; }

        [Column("user_id")]
        public long? UserId { get; set; }

        [Column("title")]
        public string? Title { get; set; }

        [Column("message")]
        public string? Message { get; set; }

        [Column("type")]
        public string? Type { get; set; }

        [Column("is_read")]
        public bool IsRead { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public User? User { get; set; }
    }
}
