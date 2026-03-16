using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    [Table("product_images")]
    public class ProductImage
    {
        [Key]
        public long Id { get; set; }

        [Column("product_id")]
        public long ProductId { get; set; }

        [Column("image_url")]
        public string ImageUrl { get; set; }

        [Column("is_main")]
        public bool IsMain { get; set; }

    }
}
