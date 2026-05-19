using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    [Table("return_requests")]
    public class ReturnRequest
    {
        public long Id { get; set; }

        [Column("order_id")]
        public long? OrderId { get; set; }

        [Column("user_id")]
        public long? UserId { get; set; }

        public string? Reason { get; set; }

        public string? Status { get; set; } = "PENDING";

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public Order? Order { get; set; }
        public User? User { get; set; }
    }
}
