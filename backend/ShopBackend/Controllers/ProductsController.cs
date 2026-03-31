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

        // ─────────────────────────────────────────────────────────────
        // GET /api/products?page=1&pageSize=10
        //      &brands=Nike,Adidas
        //      &colors=Red,Blue
        //      &sizes=S,M,L
        //      &minPrice=100000&maxPrice=500000
        //      &search=áo
        //      &sortBy=price_asc|price_desc|newest|rating
        // ─────────────────────────────────────────────────────────────
        [HttpGet]
        public async Task<IActionResult> GetProducts(
            int page = 1,
            int pageSize = 10,
            [FromQuery] List<string>? brands = null,
            [FromQuery] List<string>? colors = null,
            [FromQuery] List<string>? sizes = null,
            decimal? minPrice = null,
            decimal? maxPrice = null,
            string? search = null,
            string? sortBy = null)
        {
            // 1. Base query — join với variants để filter theo giá / thuộc tính
            var query = _db.Products.AsQueryable();

            // 2. Tìm kiếm theo tên
            if (!string.IsNullOrWhiteSpace(search))
                query = query.Where(p => p.Name.Contains(search));

            // 3. Filter theo thương hiệu
            //    Giả sử Product có cột Brand (string). Nếu lưu trong attribute thì xem chú thích bên dưới.
            if (brands != null && brands.Count > 0)
            {
                var brandsLower = brands.Select(b => b.ToLower()).ToList();
                query = query.Where(p => brandsLower.Contains(p.Brand.ToLower()));
            }

            // 4. Filter theo màu sắc & size (thông qua VariantAttributes)
            //    Chỉ giữ sản phẩm có ít nhất 1 variant thỏa cả màu lẫn size được chọn.
            if (colors != null && colors.Count > 0)
            {
                var colorsLower = colors.Select(c => c.ToLower()).ToList();
                query = query.Where(p =>
                    _db.ProductVariants
                        .Where(v => v.ProductId == p.Id)
                        .Any(v => v.VariantAttributes.Any(va =>
                            va.AttributeValue.Attribute.Name.ToLower() == "color" &&
                            colorsLower.Contains(va.AttributeValue.Value.ToLower()))));
            }

            if (sizes != null && sizes.Count > 0)
            {
                var sizesLower = sizes.Select(s => s.ToLower()).ToList();
                query = query.Where(p =>
                    _db.ProductVariants
                        .Where(v => v.ProductId == p.Id)
                        .Any(v => v.VariantAttributes.Any(va =>
                            va.AttributeValue.Attribute.Name.ToLower() == "size" &&
                            sizesLower.Contains(va.AttributeValue.Value.ToLower()))));
            }

            // 5. Filter theo khoảng giá (dựa trên giá thấp nhất của variant)
            if (minPrice.HasValue)
                query = query.Where(p =>
                    _db.ProductVariants.Where(v => v.ProductId == p.Id).Min(v => v.Price) >= minPrice.Value);

            if (maxPrice.HasValue)
                query = query.Where(p =>
                    _db.ProductVariants.Where(v => v.ProductId == p.Id).Min(v => v.Price) <= maxPrice.Value);

            // 6. Sắp xếp
            query = sortBy switch
            {
                "price_asc"  => query.OrderBy(p =>
                                    _db.ProductVariants.Where(v => v.ProductId == p.Id).Min(v => v.Price)),
                "price_desc" => query.OrderByDescending(p =>
                                    _db.ProductVariants.Where(v => v.ProductId == p.Id).Min(v => v.Price)),
                "rating"     => query.OrderByDescending(p => p.RatingAvg),
                _            => query.OrderByDescending(p => p.Id) // newest (default)
            };

            // 7. Đếm tổng (trước khi phân trang)
            var total = await query.CountAsync();

            // 8. Phân trang + project sang DTO
            var products = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(p => new ProductHomeDto
                {
                    Id     = p.Id,
                    Name   = p.Name,
                    Rating = p.RatingAvg,
                    Price  = _db.ProductVariants
                                .Where(v => v.ProductId == p.Id)
                                .Min(v => v.Price),
                    Image  = _db.ProductImages
                                .Where(i => i.ProductId == p.Id && i.IsMain)
                                .Select(i => i.ImageUrl)
                                .FirstOrDefault()
                })
                .ToListAsync();

            return Ok(new
            {
                total,
                page,
                pageSize,
                totalPages = (int)Math.Ceiling((double)total / pageSize),
                items = products
            });
        }

        // ─────────────────────────────────────────────────────────────
        // GET /api/products/home  (giữ nguyên code cũ)
        // ─────────────────────────────────────────────────────────────
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
                    Id     = p.Id,
                    Name   = p.Name,
                    Rating = p.RatingAvg,
                    Price  = _db.ProductVariants
                                .Where(v => v.ProductId == p.Id)
                                .Min(v => v.Price),
                    Image  = _db.ProductImages
                                .Where(i => i.ProductId == p.Id && i.IsMain)
                                .Select(i => i.ImageUrl)
                                .FirstOrDefault()
                })
                .ToListAsync();

            return Ok(products);
        }
    // GET /api/products/{id}  (giữ nguyên code cũ)
      
        [HttpGet("{id:long}")]
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
                            Name  = va.AttributeValue.Attribute.Name,
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
                    Name   = g.Key,
                    Values = g.Select(x => x.Value).Distinct().ToList()
                })
                .ToList();

            // 5. Variant matrix
            var variants = variantsData.Select(v => new VariantDto
            {
                VariantId  = v.Id,
                Price      = v.Price,
                Stock      = v.StockQuantity,
                Attributes = v.Attributes.ToDictionary(a => a.Name, a => a.Value)
            }).ToList();

            // 6. Images by attribute
            var imagesByVariant = await _db.ProductImages
                .Where(i => i.ProductId == id && i.VariantId != null)
                .GroupBy(i => i.VariantId)
                .Select(g => new
                {
                    variantId = g.Key!.Value,
                    image     = g.First().ImageUrl
                })
                .ToListAsync();

            var imageDict = imagesByVariant
                .ToDictionary(x => x.variantId, x => x.image);

            string? colorName = attributes
                .Select(a => a.Name)
                .FirstOrDefault(name =>
                    variants.Any(v =>
                        imageDict.ContainsKey(v.VariantId) &&
                        v.Attributes.ContainsKey(name)));

            Dictionary<string, string> imagesByColor = new();
            if (colorName != null)
            {
                imagesByColor = variants
                    .Where(v =>
                        v.Attributes.ContainsKey(colorName) &&
                        imageDict.ContainsKey(v.VariantId))
                    .GroupBy(v => v.Attributes[colorName])
                    .ToDictionary(
                        g => g.Key,
                        g => imageDict[g.First().VariantId]);
            }

            // 7. Final DTO
            var result = new ProductDetailDto
            {
                Id           = product.Id,
                Name         = product.Name,
                Description  = product.Description,
                Images       = product.Images,
                MinPrice     = minPrice,
                Rating       = (double)product.RatingAvg,
                Attributes   = attributes,
                Variants     = variants,
                ImagesByColor = imagesByColor
            };

            return Ok(result);
        }
        // ─────────────────────────────────────────────────────────────
// GET /api/products/brands
// Trả về danh sách brand duy nhất, sắp xếp theo ABC
// ─────────────────────────────────────────────────────────────
[HttpGet("brands")]
public async Task<IActionResult> GetBrands()
{
    var brands = await _db.Products
        .Where(p => !string.IsNullOrEmpty(p.Brand)) // loại bỏ null/empty
        .Select(p => p.Brand!.Trim())               // loại bỏ khoảng trắng thừa
        .Distinct()                                 // chỉ lấy duy nhất
        .OrderBy(b => b)                            // sắp xếp theo ABC
        .ToListAsync();

    return Ok(brands);
}
// GET /api/products/brand-attributes?brand=Nike
// GET /api/products/brand-attributes?brand=Nike
[HttpGet("brand-attributes")]
public async Task<IActionResult> GetBrandAttributes([FromQuery] string brand)
{
    if (string.IsNullOrEmpty(brand))
        return BadRequest("Brand is required.");

    // 1️⃣ Lấy tất cả product của brand
    var productIds = await _db.Products
        .Where(p => p.Brand != null && p.Brand.ToLower() == brand.ToLower())
        .Select(p => p.Id)
        .ToListAsync();

    // 2️⃣ Lấy tất cả VariantAttributes của các product đó bằng cách join ProductVariant
   var variantAttributes = await _db.VariantAttributes
    .Include(va => va.Variant)            // Include Variant để lấy ProductId
    .Include(va => va.AttributeValue)
        .ThenInclude(av => av.Attribute)
    .Where(va => productIds.Contains(va.Variant.ProductId)) // chỉ dùng ProductId
    .ToListAsync();

    // 3️⃣ Group theo attribute name
    var result = variantAttributes
        .GroupBy(va => va.AttributeValue.Attribute.Name) // "Size" hoặc "Color"
        .ToDictionary(
            g => g.Key,
            g => g.Select(va => va.AttributeValue.Value).Distinct().ToList()
        );

    return Ok(result); // { "Size": ["S","M"], "Color": ["Red","Blue"] }
}
    }
}