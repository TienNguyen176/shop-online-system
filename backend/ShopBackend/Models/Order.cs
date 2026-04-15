using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;


namespace ShopBackend.Models
{
    public class Order
    {
        public long Id { get; set; }

        [Column("order_code")]
        public string OrderCode { get; set; } = $"ORD_{DateTime.Now.Ticks}";

        [Column("user_id")]
        public long? UserId { get; set; }

        public string Status { get; set; } = "PENDING";

        [Column("total_price")]
        public decimal TotalPrice { get; set; }

        [Column("shipping_name")]
        public string ShippingName { get; set; }

        [Column("shipping_phone")]
        public string ShippingPhone { get; set; }

        [Column("shipping_address")]
        public string ShippingAddress { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}