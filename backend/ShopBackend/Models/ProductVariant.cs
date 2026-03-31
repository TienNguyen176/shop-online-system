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

<<<<<<< HEAD
        public string? Sku { get; set; }
=======
        public string Sku { get; set; }
>>>>>>> 4d9c391 (apply new gitignore rules)

        public decimal Price { get; set; }

        [Column("stock_quantity")]
        public int StockQuantity { get; set; }

<<<<<<< HEAD
<<<<<<< HEAD
        // ✅ Navigation property — CartController cần cái này
        [ForeignKey("ProductId")]
        public Product? Product { get; set; }

        public List<VariantAttribute>? VariantAttributes { get; set; }
    }
}
=======
        public List<VariantAttribute> VariantAttributes { get; set; }
=======
        public ICollection<VariantAttribute> Attributes { get; set; }
>>>>>>> 070fa5f (update CRUD Product (Create, Delete))

    }
}
>>>>>>> 4d9c391 (apply new gitignore rules)
