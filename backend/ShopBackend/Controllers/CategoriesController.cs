using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.DTOs;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/categories")]
    public class CategoriesController : ControllerBase
    {
        private readonly AppDbContext _db;

        public CategoriesController(AppDbContext db)
        {
            _db = db;
        }

        // GET: api/categories
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var categories = await _db.Categories
                .AsNoTracking()
                .Select(c => new CategoryDto
                {
                    Id = c.Id,
                    Name = c.Name,
                    Slug = c.Slug,
                    Image = c.Image,
                    ParentId = c.ParentId,
                    Level = c.Level,
                })
                .ToListAsync();

            return Ok(categories);
        }

        // GET: api/categories/tree
        [HttpGet("tree")]
        public async Task<IActionResult> GetCategoryTree()
        {
            var categories = await _db.Categories.AsNoTracking().ToListAsync();

            var dict = categories.ToDictionary(
                c => c.Id,
                c => new CategoryDto
                {
                    Id = c.Id,
                    Name = c.Name,
                    Slug = c.Slug,
                    Image = c.Image,
                    ParentId = c.ParentId,
                    Level = c.Level,
                });

            List<CategoryDto> roots = new();

            foreach (var c in categories)
            {
                if (c.ParentId == null)
                {
                    roots.Add(dict[c.Id]);
                }
                else if (dict.ContainsKey(c.ParentId.Value))
                {
                    dict[c.ParentId.Value].Children.Add(dict[c.Id]);
                }
            }

            return Ok(roots);
        }

        // GET: api/categories/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetCategoryById(long id)
        {
            var category = await _db.Categories.FindAsync(id);

            if (category == null)
                return NotFound();

            return Ok(category);
        }

        // POST: api/categories
        [HttpPost]
        public async Task<IActionResult> Create(CategoryDto dto)
        {
            var name = dto.Name?.Trim();
            if (string.IsNullOrWhiteSpace(name))
                return BadRequest("Tên danh mục không được để trống");

            var parent = dto.ParentId.HasValue
                ? await _db.Categories.FirstOrDefaultAsync(c => c.Id == dto.ParentId.Value)
                : null;

            if (dto.ParentId.HasValue && parent == null)
                return BadRequest("Danh mục cha không tồn tại");

            var category = new Category
            {
                Name = name,
                Slug = await UniqueSlug(dto.Slug, name),
                Image = string.IsNullOrWhiteSpace(dto.Image) ? null : dto.Image.Trim(),
                ParentId = dto.ParentId,
                Level = parent == null ? 0 : parent.Level + 1,
            };

            _db.Categories.Add(category);
            await _db.SaveChangesAsync();

            return Ok(ToDto(category));
        }

        // PUT: api/categories/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(long id, CategoryDto dto)
        {
            var category = await _db.Categories.FirstOrDefaultAsync(c => c.Id == id);
            if (category == null)
                return NotFound();

            var name = dto.Name?.Trim();
            if (string.IsNullOrWhiteSpace(name))
                return BadRequest("Tên danh mục không được để trống");

            if (dto.ParentId == id)
                return BadRequest("Danh mục cha không hợp lệ");

            if (dto.ParentId.HasValue && await IsDescendant(dto.ParentId.Value, id))
                return BadRequest("Không thể chọn danh mục con làm danh mục cha");

            var parent = dto.ParentId.HasValue
                ? await _db.Categories.FirstOrDefaultAsync(c => c.Id == dto.ParentId.Value)
                : null;

            if (dto.ParentId.HasValue && parent == null)
                return BadRequest("Danh mục cha không tồn tại");

            category.Name = name;
            category.Slug = await UniqueSlug(dto.Slug, name, id);
            category.Image = string.IsNullOrWhiteSpace(dto.Image) ? null : dto.Image.Trim();
            category.ParentId = dto.ParentId;
            category.Level = parent == null ? 0 : parent.Level + 1;

            await UpdateChildrenLevel(category.Id, category.Level);
            await _db.SaveChangesAsync();

            return Ok(ToDto(category));
        }

        // DELETE: api/categories/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(long id)
        {
            var category = await _db.Categories.FirstOrDefaultAsync(c => c.Id == id);
            if (category == null)
                return NotFound();

            var hasChildren = await _db.Categories.AnyAsync(c => c.ParentId == id);
            if (hasChildren)
                return BadRequest("Không thể xóa danh mục đang có danh mục con");

            var hasProducts = await _db.Products
                .IgnoreQueryFilters()
                .AnyAsync(p => p.CategoryId == id);
            if (hasProducts)
                return BadRequest("Không thể xóa danh mục đang có sản phẩm");

            _db.Categories.Remove(category);
            await _db.SaveChangesAsync();

            return Ok();
        }

        // GET: api/categories/slug/{slug}
        [HttpGet("slug/{slug}")]
        public async Task<IActionResult> GetBySlug(string slug)
        {
            var category = await _db.Categories
                .FirstOrDefaultAsync(c => c.Slug == slug);

            if (category == null)
                return NotFound();

            return Ok(category);
        }

        private static CategoryDto ToDto(Category category)
        {
            return new CategoryDto
            {
                Id = category.Id,
                Name = category.Name,
                Slug = category.Slug,
                Image = category.Image,
                ParentId = category.ParentId,
                Level = category.Level,
            };
        }

        private async Task<string> UniqueSlug(string? slug, string name, long? exceptId = null)
        {
            var baseSlug = Slugify(string.IsNullOrWhiteSpace(slug) ? name : slug);
            var candidate = baseSlug;
            var index = 2;

            while (await _db.Categories.AnyAsync(c => c.Slug == candidate && (!exceptId.HasValue || c.Id != exceptId.Value)))
            {
                candidate = $"{baseSlug}-{index}";
                index++;
            }

            return candidate;
        }

        private static string Slugify(string text)
        {
            var normalized = text
                .Trim()
                .ToLowerInvariant()
                .Replace("đ", "d")
                .Normalize(NormalizationForm.FormD);
            var builder = new StringBuilder();

            foreach (var ch in normalized)
            {
                var category = CharUnicodeInfo.GetUnicodeCategory(ch);
                if (category != UnicodeCategory.NonSpacingMark)
                    builder.Append(ch);
            }

            var slug = builder.ToString().Normalize(NormalizationForm.FormC);
            slug = Regex.Replace(slug, @"[^a-z0-9]+", "-").Trim('-');
            return string.IsNullOrWhiteSpace(slug) ? "danh-muc" : slug;
        }

        private async Task<bool> IsDescendant(long candidateId, long parentId)
        {
            var current = await _db.Categories.FirstOrDefaultAsync(c => c.Id == candidateId);
            while (current?.ParentId != null)
            {
                if (current.ParentId == parentId) return true;
                current = await _db.Categories.FirstOrDefaultAsync(c => c.Id == current.ParentId.Value);
            }

            return false;
        }

        private async Task UpdateChildrenLevel(long parentId, int parentLevel)
        {
            var children = await _db.Categories.Where(c => c.ParentId == parentId).ToListAsync();
            foreach (var child in children)
            {
                child.Level = parentLevel + 1;
                await UpdateChildrenLevel(child.Id, child.Level);
            }
        }
    }
}
