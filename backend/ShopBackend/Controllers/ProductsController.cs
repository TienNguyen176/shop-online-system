using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.DTOs;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/products")]
    public class ProductsController : ControllerBase
    {
        private readonly AppDbContext _db;

        public ProductsController(AppDbContext db)
        {
            _db = db;
        }

        // Danh sách sản phẩm cho trang chủ
        [HttpGet("home")]
        public async Task<IActionResult> GetHomeProducts(
        int page = 1,
        int pageSize = 10)
        {

            var products = await _db.Products

                .OrderByDescending(p => p.Id)

                .Skip((page - 1) * pageSize)
                .Take(pageSize)

                .Select(p => new ProductHomeDto
                {
                    Id = p.Id,

                    Name = p.Name,

                    Rating = p.RatingAvg,

                    Price = _db.ProductVariants
                        .Where(v => v.ProductId == p.Id)
                        .Min(v => v.Price),

                    Image = _db.ProductImages
                        .Where(i => i.ProductId == p.Id && i.IsMain)
                        .Select(i => i.ImageUrl)
                        .FirstOrDefault()
                })

                .ToListAsync();

            return Ok(products);
        }

        // Chi tiết sản phẩm
        [HttpGet("{id}")]
        public async Task<IActionResult> GetProductDetail(long id)
        {
            // 1. Load product
            var product = await _db.Products
                .Where(p => p.Id == id)
                .Select(p => new
                {
                    p.Id,
                    p.Name,
                    p.Description,
                    p.RatingAvg,

                    Images = _db.ProductImages
                        .Where(i => i.ProductId == p.Id && i.VariantId == null)
                        .OrderByDescending(i => i.IsMain)
                        .ThenBy(i => i.Id)
                        .Select(i => i.ImageUrl)
                        .ToList()
                })
                .FirstOrDefaultAsync();

            if (product == null)
                return NotFound();

            // 2. Load variants
            var variantsData = await _db.ProductVariants
                .Where(v => v.ProductId == id)
                .Select(v => new
                {
                    v.Id,
                    v.Price,
                    v.Sku,
                    v.StockQuantity,

                    Attributes = v.VariantAttributes
                        .Select(va => new
                        {
                            Name = va.AttributeValue.Attribute.Name,
                            Value = va.AttributeValue.Value
                        }).ToList()
                })
                .ToListAsync();

            if (!variantsData.Any())
                return NotFound();

            // 3. Min price
            var minPrice = variantsData.Min(v => v.Price);

            // 4. Group attributes
            var attributes = variantsData
                .SelectMany(v => v.Attributes)
                .GroupBy(a => a.Name)
                .Select(g => new AttributeDto
                {
                    Name = g.Key,
                    Values = g.Select(x => x.Value).Distinct().ToList()
                })
                .ToList();

            // 5. Variant matrix
            var variants = variantsData.Select(v => new VariantDto
            {
                VariantId = v.Id,
                Price = v.Price,
                Stock = v.StockQuantity,
                Attributes = v.Attributes.ToDictionary(a => a.Name, a => a.Value)
            }).ToList();

            // 6. Images by attribute
            // Get all images for variants of this product
            var imagesByVariant = await _db.ProductImages
                .Where(i => i.ProductId == id && i.VariantId != null)
                .GroupBy(i => i.VariantId!.Value)
                .Select(g => new
                {
                    variantId = g.Key,
                    image = g
                        .OrderByDescending(x => x.IsMain)
                        .ThenBy(x => x.Id)
                        .Select(x => x.ImageUrl)
                        .FirstOrDefault()
                })
                .ToListAsync();

            // Convert to dictionary for quick lookup
            var imageDict = imagesByVariant
                .ToDictionary(x => x.variantId, x => x.image);

            // Find the first attribute that has images (e.g. color)
            string? colorName = attributes
                .Select(a => a.Name)
                .FirstOrDefault(name =>
                    variants.Any(v =>
                        imageDict.ContainsKey(v.VariantId) &&
                        v.Attributes.ContainsKey(name)
                    )
                );

            // Build imagesByColor
            Dictionary<string, string> imagesByColor = new();

            if (colorName != null)
            {
                imagesByColor = variants
                    .Where(v =>
                        v.Attributes.ContainsKey(colorName) &&
                        imageDict.ContainsKey(v.VariantId) &&
                        imageDict[v.VariantId] != null
                    )
                    .GroupBy(v => v.Attributes[colorName])
                    .ToDictionary(
                        g => g.Key,
                        g => imageDict[g.First().VariantId]!
                    );
            }

            // 7. Final DTO
            var result = new ProductDetailDto
            {
                Id = product.Id,
                Name = product.Name,
                Description = product.Description,
                Images = product.Images,
                MinPrice = minPrice,
                Rating = (double)product.RatingAvg,
                Attributes = attributes,
                Variants = variants,
                ImagesByColor = imagesByColor
            };

            return Ok(result);
        }
    }
}
