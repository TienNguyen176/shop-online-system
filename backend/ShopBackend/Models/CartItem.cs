using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    [Table("cart_items")]
    public class CartItem
    {
        [Key]
        public long Id { get; set; }

        [Column("cart_id")]
        public long CartId { get; set; }

        [Column("variant_id")]
        public long VariantId { get; set; }

        public int Quantity { get; set; }

        // Navigation
        [ForeignKey("VariantId")]
        public ProductVariant? Variant { get; set; }
    }
}