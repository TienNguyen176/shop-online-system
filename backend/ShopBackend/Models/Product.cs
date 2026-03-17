using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    public class Product
    {
        [Key]
        public long Id { get; set; }

        public string Name { get; set; }

        public string Description { get; set; }

        [Column("category_id")]
        public long? CategoryId { get; set; }

        public string Brand { get; set; }

        [Column("rating_avg")]
        public decimal RatingAvg { get; set; }

        [Column("rating_count")]
        public int RatingCount { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; }

    }
}
