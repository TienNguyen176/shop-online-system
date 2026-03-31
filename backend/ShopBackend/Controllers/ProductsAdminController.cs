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
        public async Task<IActionResult> GetAllProducts(int page = 1, int pageSize = 10) { var query = from p in _db.Products join c in _db.Categories on p.CategoryId equals c.Id into pc from c in pc.DefaultIfEmpty() select new { p.Id, p.Name, p.Brand, p.Description, CategoryId = p.CategoryId, CategoryName = c != null ? c.Name : null, Rating = p.RatingAvg, Image = _db.ProductImages.Where(i => i.ProductId == p.Id && i.IsMain).Select(i => i.ImageUrl).FirstOrDefault() }; var total = await query.CountAsync(); var data = await query.OrderByDescending(p => p.Id).Skip((page - 1) * pageSize).Take(pageSize).ToListAsync(); return Ok(new { total, page, pageSize, data }); }

        // =========================
        // CREATE
        // =========================
        [HttpPost]
        public async Task<IActionResult> CreateProduct([FromBody] AdminProductDto dto)
        {
            if (dto == null || string.IsNullOrWhiteSpace(dto.Name))
                return BadRequest("Invalid data");

            if (dto.Variants == null || !dto.Variants.Any())
                return BadRequest("Variants required");

            await using var tx = await _db.Database.BeginTransactionAsync();

            try
            {
                var product = new Product
                {
                    Name = dto.Name,
                    Description = dto.Description,
                    CategoryId = dto.CategoryId,
                    Brand = dto.Brand
                };

                _db.Products.Add(product);
                await _db.SaveChangesAsync();

                // CACHE ATTRIBUTES
                var attributeCache = await _db.Attributes
                    .ToDictionaryAsync(a => a.Name, a => a);

                var attributeValueCache = await _db.AttributeValues
                    .ToDictionaryAsync(av => $"{av.AttributeId}_{av.Value}", av => av);

                var variants = new List<ProductVariant>();

                foreach (var v in dto.Variants)
                {
                    var variant = new ProductVariant
                    {
                        ProductId = product.Id,
                        Price = v.Price,
                        StockQuantity = v.StockQuantity
                    };

                    variants.Add(variant);
                }

                _db.ProductVariants.AddRange(variants);
                await _db.SaveChangesAsync();

                var variantAttributes = new List<VariantAttribute>();

                for (int i = 0; i < dto.Variants.Count; i++)
                {
                    var vDto = dto.Variants[i];
                    var variant = variants[i];

                    if (vDto.Attributes == null) continue;

                    foreach (var kv in vDto.Attributes)
                    {
                        var name = kv.Key.Trim();
                        var value = kv.Value.Trim();

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
                            VariantId = variant.Id,
                            AttributeValueId = attrValue.Id
                        });
                    }
                }

                _db.VariantAttributes.AddRange(variantAttributes);
                await _db.SaveChangesAsync();

                // SKU
                foreach (var v in variants)
                {
                    v.Sku = $"{Slugify(product.Brand)}-{product.Id}-{Guid.NewGuid().ToString()[..6]}";
                }

                await _db.SaveChangesAsync();

                // IMAGES
                if (dto.Images != null)
                {
                    var images = new List<ProductImage>();

                    foreach (var img in dto.Images)
                    {
                        int? variantId = null;

                        if (img.VariantIndex.HasValue &&
                            img.VariantIndex.Value < variants.Count)
                        {
                            variantId = (int?)variants[img.VariantIndex.Value].Id;
                        }

                        images.Add(new ProductImage
                        {
                            ProductId = product.Id,
                            VariantId = variantId,
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
        // UPDATE (RECREATE)
        // =========================
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateProduct(long id, [FromBody] AdminProductDto dto)
        {
            var product = await _db.Products.FindAsync(id);
            if (product == null) return NotFound();

            await using var tx = await _db.Database.BeginTransactionAsync();

            try
            {
                product.Name = dto.Name;
                product.Description = dto.Description;
                product.CategoryId = dto.CategoryId;
                product.Brand = dto.Brand;

                // DELETE ALL OLD
                var variantIds = await _db.ProductVariants
                    .Where(x => x.ProductId == id)
                    .Select(x => x.Id)
                    .ToListAsync();

                _db.VariantAttributes.RemoveRange(
                    _db.VariantAttributes.Where(x => variantIds.Contains(x.VariantId)));

                _db.ProductImages.RemoveRange(
                    _db.ProductImages.Where(x => x.ProductId == id));

                _db.ProductVariants.RemoveRange(
                    _db.ProductVariants.Where(x => x.ProductId == id));

                await _db.SaveChangesAsync();

                // REUSE CREATE LOGIC
                dto.CategoryId = product.CategoryId;

                var createResult = await CreateProduct(dto) as OkObjectResult;

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
                .Include(p => p.Variants)
                    .ThenInclude(v => v.Attributes)
                .Include(p => p.Images)
                .FirstOrDefaultAsync(p => p.Id == id);

            if (product == null) return NotFound();

            // delete children first
            _db.VariantAttributes.RemoveRange(
                product.Variants.SelectMany(v => v.Attributes)
            );

            _db.ProductVariants.RemoveRange(product.Variants);
            _db.ProductImages.RemoveRange(product.Images);

            _db.Products.Remove(product);

            await _db.SaveChangesAsync();

            return NoContent();
        }

        // =========================
        // UPLOAD IMAGE
        // =========================
        [HttpPost("{id}/upload-image")]
        public async Task<IActionResult> UploadImage(long id, IFormFile file)
        {
            if (file == null || file.Length == 0)
                return BadRequest("File empty");

            var allowed = new[] { ".jpg", ".jpeg", ".png", ".webp" };
            var ext = Path.GetExtension(file.FileName).ToLower();

            if (!allowed.Contains(ext))
                return BadRequest("Invalid file");

            if (file.Length > 5 * 1024 * 1024)
                return BadRequest("Max 5MB");

            var folder = Path.Combine("wwwroot/uploads/products", id.ToString());
            Directory.CreateDirectory(folder);

            var fileName = $"{Guid.NewGuid()}{ext}";
            var path = Path.Combine(folder, fileName);

            using var stream = new FileStream(path, FileMode.Create);
            await file.CopyToAsync(stream);

            var url = $"uploads/products/{id}/{fileName}";

            var img = new ProductImage
            {
                ProductId = id,
                ImageUrl = url,
                IsMain = !_db.ProductImages.Any(x => x.ProductId == id)
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
    }
}