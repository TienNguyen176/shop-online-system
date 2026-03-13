using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/products")]
    public class ProductController : ControllerBase
    {
        private readonly AppDbContext _db;

        public ProductController(AppDbContext db)
        {
            _db = db;
        }

        // Danh sách sản phẩm
        [HttpGet]
        public async Task<IActionResult> GetProducts()
        {
            var products = await _db.Products
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();

            return Ok(products);
        }

        // Sản phẩm hot
        [HttpGet("hot")]
        public async Task<IActionResult> GetHotProducts()
        {
            var products = await _db.Products
                .Where(x => x.IsHot)
                .ToListAsync();

            return Ok(products);
        }

        // Chi tiết sản phẩm
        [HttpGet("{id}")]
        public async Task<IActionResult> GetProduct(int id)
        {
            var product = await _db.Products
                .FirstOrDefaultAsync(x => x.Id == id);

            if (product == null)
                return NotFound();

            return Ok(product);
        }
    }
}
