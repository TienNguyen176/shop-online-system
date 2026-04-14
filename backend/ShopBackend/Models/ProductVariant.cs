using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    [Table("product_variants")]
    public class ProductVariant
    {
        [Key]
        public long Id { get; set; }

        [Column("product_id")]
        public long ProductId { get; set; }

        public string Sku { get; set; }

        public decimal Price { get; set; }

        [Column("stock_quantity")]
        public int StockQuantity { get; set; }

        // Navigation property — CartController needs to include this when fetching cart items
        [ForeignKey("ProductId")]
        public Product? Product { get; set; }

        public ICollection<VariantAttribute> Attributes { get; set; }

    }
}
