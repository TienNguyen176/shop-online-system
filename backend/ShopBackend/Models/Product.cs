using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    public class Product
    {
        [Key]
        public long Id { get; set; }

        public required string Name { get; set; }

        public required string Description { get; set; }

        [Column("category_id")]
        public long? CategoryId { get; set; }

        public required string Brand { get; set; }

        [Column("rating_avg")]
        public decimal RatingAvg { get; set; }

        [Column("rating_count")]
        public int RatingCount { get; set; }

        [Column("sold_count")]
        public int SoldCount { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; }

        // Navigation properties
        public ICollection<ProductImage> ProductImages { get; set; }
            = new List<ProductImage>();

        public ICollection<ProductVariant> ProductVariants { get; set; }
            = new List<ProductVariant>();

        public Category? Category { get; set; }
    }
}
