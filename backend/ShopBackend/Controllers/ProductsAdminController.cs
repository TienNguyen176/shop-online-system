using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.Models;
using ShopBackend.DTOs;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/admin/products")]
    public class ProductsAdminController : ControllerBase
    {
        private readonly AppDbContext _db;

        public ProductsAdminController(AppDbContext db)
        {
            _db = db;
        }

        // =========================
        // GET ALL
        // =========================
        [HttpGet]
        public async Task<IActionResult> GetAllProducts(int page = 1, int pageSize = 10)
        {
            var query =
                from p in _db.Products.IgnoreQueryFilters()
                where p.IsDeleted == false
                join c in _db.Categories
                    on p.CategoryId equals c.Id into pc
                from c in pc.DefaultIfEmpty()

                join img in _db.ProductImages
                    on p.Id equals img.ProductId into pi
                from img in pi
                    .Where(i => i.IsMain)
                    .DefaultIfEmpty()

                select new
                {
                    p.Id,
                    p.Name,
                    p.Brand,
                    p.Description,

                    CategoryId = p.CategoryId,
                    CategoryName = c != null ? c.Name : null,

                    Rating = p.RatingAvg,

                    Image = img != null ? img.ImageUrl : null
                };

            var total = await query.CountAsync();

            var data = await query
                .OrderByDescending(p => p.Id)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return Ok(new
            {
                total,
                page,
                pageSize,
                data
            });
        }

        // =========================
        // CREATE
        // =========================
        [HttpPost]
        public async Task<IActionResult> CreateProduct([FromBody] AdminProductDto dto)
        {
            if (dto == null || string.IsNullOrWhiteSpace(dto.Name))
                return BadRequest("Invalid data");

            await using var tx = await _db.Database.BeginTransactionAsync();

            try
            {
                var product = new Product
                {
                    Name = dto.Name.Trim(),
                    Description = dto.Description ?? string.Empty,
                    CategoryId = dto.CategoryId,
                    Brand = dto.Brand ?? string.Empty,
                    CreatedAt = DateTime.UtcNow
                };

                _db.Products.Add(product);
                await _db.SaveChangesAsync();

                if (dto.Images != null)
                {
                    var images = new List<ProductImage>();

                    foreach (var img in dto.Images)
                    {
                        images.Add(new ProductImage
                        {
                            ProductId = product.Id,
                            ImageUrl = img.ImageUrl,
                            IsMain = img.IsMain
                        });
                    }

                    _db.ProductImages.AddRange(images);
                    await _db.SaveChangesAsync();
                }

                await tx.CommitAsync();

                return Ok(new { id = product.Id });
            }
            catch (Exception ex)
            {
                await tx.RollbackAsync();
                return StatusCode(500, ex.Message);
            }
        }

        // =========================
        // UPDATE
        // =========================
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateProduct(long id, [FromBody] AdminProductDto dto)
        {
            var product = await _db.Products.FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted);
            if (product == null) return NotFound();

            if (dto == null || string.IsNullOrWhiteSpace(dto.Name))
                return BadRequest("Invalid data");

            await using var tx = await _db.Database.BeginTransactionAsync();

            try
            {
                product.Name = dto.Name.Trim();
                product.Description = dto.Description ?? string.Empty;
                product.CategoryId = dto.CategoryId;
                product.Brand = dto.Brand ?? string.Empty;

                await _db.SaveChangesAsync();

                await tx.CommitAsync();

                return Ok(new { id });
            }
            catch (Exception ex)
            {
                await tx.RollbackAsync();
                return StatusCode(500, ex.Message);
            }
        }

        // =========================
        // DELETE
        // =========================
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProduct(long id)
        {
            var product = await _db.Products
                .IgnoreQueryFilters()
                .FirstOrDefaultAsync(p => p.Id == id);

            if (product == null) return NotFound();

            if (product.IsDeleted)
                return NoContent();

            product.IsDeleted = true;
            await _db.SaveChangesAsync();

            return NoContent();
        }

        // =========================
        // GET VARIANTS
        // =========================
        [HttpGet("{id}/variants")]
        public async Task<IActionResult> GetVariants(long id)
        {
            var productExists = await _db.Products.AnyAsync(x => x.Id == id && !x.IsDeleted);
            if (!productExists) return NotFound();

            var variantsData = await _db.ProductVariants
                .Where(v => v.ProductId == id)
                .Include(v => v.Attributes)
                    .ThenInclude(va => va.AttributeValue)
                    .ThenInclude(av => av.Attribute)
                .OrderByDescending(v => v.Id)
                .ToListAsync();

            var variants = variantsData
                .Select(v => new
                {
                    id = v.Id,
                    sku = v.Sku,
                    price = v.Price,
                    stockQuantity = v.StockQuantity,
                    attributes = (v.Attributes ?? new List<VariantAttribute>())
                        .ToDictionary(
                            va => va.AttributeValue.Attribute.Name,
                            va => va.AttributeValue.Value
                        )
                })
                .ToList();

            return Ok(variants);
        }

        // =========================
        // CREATE VARIANT
        // =========================
        [HttpPost("{id}/variants")]
        public async Task<IActionResult> CreateVariant(long id, [FromBody] VariantCreateDto dto)
        {
            var product = await _db.Products.FirstOrDefaultAsync(x => x.Id == id && !x.IsDeleted);
            if (product == null) return NotFound();

            await using var tx = await _db.Database.BeginTransactionAsync();

            try
            {
                var variant = new ProductVariant
                {
                    ProductId = id,
                    Price = dto.Price,
                    StockQuantity = dto.StockQuantity,
                    Sku = string.IsNullOrWhiteSpace(dto.Sku)
                        ? $"{Slugify(product.Brand)}-{id}-{Guid.NewGuid().ToString()[..6]}"
                        : dto.Sku.Trim(),
                    Attributes = new List<VariantAttribute>()
                };

                _db.ProductVariants.Add(variant);
                await _db.SaveChangesAsync();

                await SaveVariantAttributes(variant.Id, dto.Attributes);

                await tx.CommitAsync();

                return Ok(new { id = variant.Id });
            }
            catch (Exception ex)
            {
                await tx.RollbackAsync();
                return StatusCode(500, ex.Message);
            }
        }

        // =========================
        // UPDATE VARIANT
        // =========================
        [HttpPut("{id}/variants/{variantId}")]
        public async Task<IActionResult> UpdateVariant(long id, long variantId, [FromBody] VariantCreateDto dto)
        {
            var productExists = await _db.Products.AnyAsync(x => x.Id == id && !x.IsDeleted);
            if (!productExists) return NotFound();

            var variant = await _db.ProductVariants
                .FirstOrDefaultAsync(x => x.Id == variantId && x.ProductId == id);

            if (variant == null) return NotFound();

            await using var tx = await _db.Database.BeginTransactionAsync();

            try
            {
                variant.Price = dto.Price;
                variant.StockQuantity = dto.StockQuantity;

                if (!string.IsNullOrWhiteSpace(dto.Sku))
                    variant.Sku = dto.Sku.Trim();

                _db.VariantAttributes.RemoveRange(
                    _db.VariantAttributes.Where(x => x.VariantId == variantId)
                );

                await _db.SaveChangesAsync();
                await SaveVariantAttributes(variant.Id, dto.Attributes);

                await tx.CommitAsync();

                return Ok(new { id = variant.Id });
            }
            catch (Exception ex)
            {
                await tx.RollbackAsync();
                return StatusCode(500, ex.Message);
            }
        }

        // =========================
        // DELETE VARIANT
        // =========================
        [HttpDelete("{id}/variants/{variantId}")]
        public async Task<IActionResult> DeleteVariant(long id, long variantId)
        {
            var productExists = await _db.Products.AnyAsync(x => x.Id == id && !x.IsDeleted);
            if (!productExists) return NotFound();

            var variant = await _db.ProductVariants
                .FirstOrDefaultAsync(x => x.Id == variantId && x.ProductId == id);

            if (variant == null) return NotFound();

            _db.VariantAttributes.RemoveRange(
                _db.VariantAttributes.Where(x => x.VariantId == variantId)
            );
            _db.ProductImages.RemoveRange(
                _db.ProductImages.Where(x => x.VariantId == variantId)
            );
            _db.ProductVariants.Remove(variant);

            await _db.SaveChangesAsync();

            return NoContent();
        }

        // =========================
        // UPLOAD IMAGE
        // =========================
        [HttpPost("{id}/upload-image")]
        public async Task<IActionResult> UploadImage(long id, IFormFile file)
        {
            var productExists = await _db.Products.AnyAsync(x => x.Id == id && !x.IsDeleted);
            if (!productExists) return NotFound();

            if (file == null || file.Length == 0)
                return BadRequest("File empty");

            var allowed = new[] { ".jpg", ".jpeg", ".png", ".webp" };
            var ext = Path.GetExtension(file.FileName).ToLower();

            if (!allowed.Contains(ext))
                return BadRequest("Invalid file");

            if (file.Length > 5 * 1024 * 1024)
                return BadRequest("Max 5MB");

            var folder = Path.Combine("wwwroot", "uploads", "images", "products", id.ToString());
            Directory.CreateDirectory(folder);

            var fileName = $"{Guid.NewGuid()}{ext}";
            var path = Path.Combine(folder, fileName);

            using var stream = new FileStream(path, FileMode.Create);
            await file.CopyToAsync(stream);

            const string productUploadPath = "uploads/images/products/";
            var url = $"{productUploadPath}{id}/{fileName}";

            var img = new ProductImage
            {
                ProductId = id,
                ImageUrl = url,
                IsMain = !await _db.ProductImages.AnyAsync(x => x.ProductId == id)
            };

            _db.ProductImages.Add(img);
            await _db.SaveChangesAsync();

            return Ok(new { url });
        }

        // =========================
        // HELPER
        // =========================
        private string Slugify(string text)
        {
            if (string.IsNullOrEmpty(text)) return "xxx";

            text = text.ToLower().Trim();
            text = System.Text.RegularExpressions.Regex
                .Replace(text, @"[^a-z0-9]", "");

            return text.Length >= 3 ? text[..3] : text.PadRight(3, 'x');
        }

        private async Task SaveVariantAttributes(
            long variantId,
            Dictionary<string, string>? attributes)
        {
            if (attributes == null || !attributes.Any()) return;

            var attributeCache = await _db.Attributes
                .ToDictionaryAsync(a => a.Name, a => a);

            var attributeValueCache = await _db.AttributeValues
                .ToDictionaryAsync(av => $"{av.AttributeId}_{av.Value}", av => av);

            var variantAttributes = new List<VariantAttribute>();

            foreach (var kv in attributes)
            {
                var name = kv.Key.Trim();
                var value = kv.Value.Trim();

                if (string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(value))
                    continue;

                if (!attributeCache.TryGetValue(name, out var attr))
                {
                    attr = new ProductAttribute { Name = name };
                    _db.Attributes.Add(attr);
                    await _db.SaveChangesAsync();
                    attributeCache[name] = attr;
                }

                var key = $"{attr.Id}_{value}";
                if (!attributeValueCache.TryGetValue(key, out var attrValue))
                {
                    attrValue = new AttributeValue
                    {
                        AttributeId = attr.Id,
                        Value = value
                    };
                    _db.AttributeValues.Add(attrValue);
                    await _db.SaveChangesAsync();
                    attributeValueCache[key] = attrValue;
                }

                variantAttributes.Add(new VariantAttribute
                {
                    VariantId = variantId,
                    AttributeValueId = attrValue.Id
                });
            }

            if (variantAttributes.Any())
            {
                _db.VariantAttributes.AddRange(variantAttributes);
                await _db.SaveChangesAsync();
            }
        }
    }
}
