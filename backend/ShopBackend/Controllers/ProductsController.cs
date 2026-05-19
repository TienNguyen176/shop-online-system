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

        // GET: api/products
        [HttpGet]
        public async Task<IActionResult> GetProducts(
            int page = 1,
            int pageSize = 10,
            long? categoryId = null,
            string? categoryIds = null,
            string? search = null,
            string? brand = null,
            string? brands = null,
            decimal? minRating = null,
            decimal? minPrice = null,
            decimal? maxPrice = null)
        {
            var query = _db.Products.AsQueryable();

            if (!string.IsNullOrWhiteSpace(search))
            {
                query = query.Where(p => p.Name.Contains(search));
            }

            if (!string.IsNullOrWhiteSpace(brand))
            {
                query = query.Where(p => p.Brand == brand);
            }

            if (!string.IsNullOrWhiteSpace(brands))
            {
                var brandList = brands
                    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                    .ToList();

                query = query.Where(p => brandList.Contains(p.Brand));
            }

            if (minRating.HasValue)
            {
                query = query.Where(p => p.RatingAvg >= minRating.Value);
            }

            if (categoryId.HasValue && categoryId != 0)
            {
                var childCategoryIds = await GetAllChildIds(categoryId.Value);

                query = query.Where(p =>
                    p.CategoryId.HasValue &&
                    childCategoryIds.Contains(p.CategoryId.Value)
                );
            }

            if (!string.IsNullOrWhiteSpace(categoryIds))
            {
                var selectedIds = categoryIds
                    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                    .Select(long.Parse)
                    .ToList();

                var expandedIds = new List<long>();
                foreach (var id in selectedIds)
                {
                    expandedIds.AddRange(await GetAllChildIds(id));
                }

                query = query.Where(p =>
                    p.CategoryId.HasValue &&
                    expandedIds.Contains(p.CategoryId.Value)
                );
            }

            if (minPrice.HasValue || maxPrice.HasValue)
            {
                query = query.Where(p =>
                    _db.ProductVariants.Any(v =>
                        v.ProductId == p.Id &&
                        (!minPrice.HasValue || v.Price >= minPrice.Value) &&
                        (!maxPrice.HasValue || v.Price <= maxPrice.Value)
                    )
                );
            }

            var products = await query
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
                        .Select(v => (decimal?)v.Price)
                        .Min() ?? 0,

                    Image = _db.ProductImages
                        .Where(i => i.ProductId == p.Id && i.IsMain)
                        .Select(i => i.ImageUrl)
                        .FirstOrDefault()
                })
                .ToListAsync();

            return Ok(products);
        }

        // GET: api/products/brands
        [HttpGet("brands")]
        public async Task<IActionResult> GetBrands()
        {
            var brands = await _db.Products
                .Where(p => p.Brand != null && p.Brand != "")
                .Select(p => p.Brand)
                .Distinct()
                .OrderBy(b => b)
                .ToListAsync();

            return Ok(brands);
        }

        // GET: api/products/banner
        [HttpGet("banner")]
        public async Task<IActionResult> GetBannerProducts()
        {
            var products = await _db.Products
                .OrderByDescending(p => p.CreatedAt)
                .ThenByDescending(p => p.SoldCount)
                .Take(5)
                .Select(p => new ProductHomeDto
                {
                    Id = p.Id,
                    Name = p.Name,
                    Rating = p.RatingAvg,
                    SoldCount = p.SoldCount,
                    CreatedAt = p.CreatedAt,

                    Price = _db.ProductVariants
                        .Where(v => v.ProductId == p.Id)
                        .Select(v => (decimal?)v.Price)
                        .Min() ?? 0,

                    Image = _db.ProductImages
                        .Where(i => i.ProductId == p.Id && i.IsMain)
                        .Select(i => i.ImageUrl)
                        .FirstOrDefault()
                })
                .ToListAsync();

            return Ok(products);
        }

        private async Task<List<long>> GetAllChildIds(long parentId)
        {
            var result = new List<long> { parentId };

            var children = await _db.Categories
                .Where(c => c.ParentId == parentId)
                .ToListAsync();

            foreach (var child in children)
            {
                result.AddRange(await GetAllChildIds(child.Id));
            }

            return result;
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
                    p.SoldCount,

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

                    Attributes = v.Attributes
                        .Select(va => new
                        {
                            Id = va.AttributeValue.Attribute.Id,
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
                    Id = g.First().Id,
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
                SoldCount = product.SoldCount,
                Attributes = attributes,
                Variants = variants,
                ImagesByColor = imagesByColor
            };

            return Ok(result);
        }
    }
}
