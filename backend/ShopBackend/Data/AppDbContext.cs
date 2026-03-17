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

        public DbSet<VariantAttribute> VariantAttributes { get; set; }

        public DbSet<AttributeValue> AttributeValues { get; set; }

        public DbSet<ProductAttribute> Attributes { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<VariantAttribute>()
                .HasKey(x => new { x.VariantId, x.AttributeValueId });

            modelBuilder.Entity<VariantAttribute>()
                .HasOne(x => x.Variant)
                .WithMany(v => v.VariantAttributes)
                .HasForeignKey(x => x.VariantId);

            modelBuilder.Entity<VariantAttribute>()
                .HasOne(x => x.AttributeValue)
                .WithMany()
                .HasForeignKey(x => x.AttributeValueId);
        }

        public DbSet<Category> Categories { get; set; }

    }
 }
