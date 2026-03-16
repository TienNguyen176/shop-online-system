using Microsoft.EntityFrameworkCore;
using ShopBackend.Models;

namespace ShopBackend.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {

        }

        public DbSet<Product> Products { get; set; }

        public DbSet<ProductImage> ProductImages { get; set; }

        public DbSet<ProductVariant> ProductVariants { get; set; }

    }
}
