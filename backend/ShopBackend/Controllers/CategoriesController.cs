using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.DTOs;

[ApiController]
[Route("api/categories")]
public class CategoriesController : ControllerBase
{
    private readonly AppDbContext _db;

    public CategoriesController(AppDbContext db)
    {
        _db = db;
    }

    // GET: api/categories/tree
    [HttpGet("tree")]
    public async Task<IActionResult> GetCategoryTree()
    {
        var categories = await _db.Categories.AsNoTracking().ToListAsync();

        // Map sang DTO
        var dict = categories.ToDictionary(
            c => c.Id,
            c => new CategoryDto
            {
                Id = c.Id,
                Name = c.Name,
                Slug = c.Slug,
                Image = c.Image
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
}