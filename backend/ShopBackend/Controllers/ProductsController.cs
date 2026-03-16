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


        //// Chi tiết sản phẩm
        //[HttpGet("{id}")]
        //public async Task<IActionResult> GetProduct(int id)
        //{
        //    var product = await _db.Products
        //        .FirstOrDefaultAsync(x => x.Id == id);

        //    if (product == null)
        //        return NotFound();

        //    return Ok(product);
        //}
    }
}
