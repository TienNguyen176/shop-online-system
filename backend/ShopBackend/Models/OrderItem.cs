using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;


namespace ShopBackend.Models
{
    [Table("order_items")]
    public class OrderItem
    {
        public long Id { get; set; }

        [Column("order_id")]
        public long OrderId { get; set; }

        [Column("product_id")]
        public long ProductId { get; set; }

        [Column("variant_id")]
        public long VariantId { get; set; }

        // snapshot
        [Column("product_name")]
        public string ProductName { get; set; }

        [Column("variant_name")]
        public string VariantName { get; set; }

        public int Quantity { get; set; }
        
        public decimal Price { get; set; }

        public decimal Total => Quantity * Price;
    }
}