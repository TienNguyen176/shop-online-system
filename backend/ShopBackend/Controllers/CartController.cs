using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.DTOs;
using ShopBackend.Models;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/cart")]
    public class CartController : ControllerBase
    {
        private readonly AppDbContext _db;

        public CartController(AppDbContext db)
        {
            _db = db;
        }

        // ➕ ADD TO CART
        [HttpPost("add")]
        public async Task<IActionResult> AddToCart([FromBody] AddToCartDto dto)
        {
            var userId = dto.UserId == 0 ? 1 : dto.UserId;

            var cart = await _db.Carts.FirstOrDefaultAsync(c => c.UserId == userId);
            if (cart == null)
            {
                cart = new Cart { UserId = userId };
                _db.Carts.Add(cart);
                await _db.SaveChangesAsync();
            }

            var item = await _db.CartItems.FirstOrDefaultAsync(x =>
                x.CartId == cart.Id && x.VariantId == dto.VariantId);

            if (item != null)
                item.Quantity += dto.Quantity;
            else
                _db.CartItems.Add(new CartItem
                {
                    CartId    = cart.Id,
                    VariantId = dto.VariantId,
                    Quantity  = dto.Quantity,
                });

            await _db.SaveChangesAsync();
            return Ok(new { message = "Added to cart" });
        }

        // 📦 GET CART
        [HttpGet("{userId}")]
        public async Task<IActionResult> GetCart(int userId)
        {
            var cart = await _db.Carts.FirstOrDefaultAsync(c => c.UserId == userId);
            if (cart == null) return Ok(new List<object>());

            var items = await _db.CartItems
                .Where(x => x.CartId == cart.Id)
                .Include(x => x.Variant)
                    .ThenInclude(v => v!.Product)
                        .ThenInclude(p => p!.ProductImages)
                .Select(x => new
                {
                    id        = x.Id,
                    quantity  = x.Quantity,
                    variantId = x.VariantId,
                    name      = x.Variant != null && x.Variant.Product != null
                                    ? x.Variant.Product.Name : "",
                    price     = x.Variant != null ? x.Variant.Price : 0,
                    image     = x.Variant != null && x.Variant.Product != null
                                    ? x.Variant.Product.ProductImages
                                        .Where(i => i.IsMain)
                                        .Select(i => i.ImageUrl)
                                        .FirstOrDefault() ?? ""
                                    : "",
                })
                .ToListAsync();

            return Ok(items);
        }

        // ✏️ UPDATE QUANTITY
        [HttpPut("update/{itemId}")]
        public async Task<IActionResult> UpdateQuantity(long itemId, [FromBody] UpdateCartDto dto)
        {
            var item = await _db.CartItems.FindAsync(itemId);
            if (item == null) return NotFound();

            if (dto.Quantity <= 0)
            {
                _db.CartItems.Remove(item);
            }
            else
            {
                item.Quantity = dto.Quantity;
            }

            await _db.SaveChangesAsync();
            return Ok(new { message = "Updated" });
        }

        // 🗑️ DELETE ITEM
        [HttpDelete("delete/{itemId}")]
        public async Task<IActionResult> DeleteItem(long itemId)
        {
            var item = await _db.CartItems.FindAsync(itemId);
            if (item == null) return NotFound();

            _db.CartItems.Remove(item);
            await _db.SaveChangesAsync();
            return Ok(new { message = "Deleted" });
        }
    }
}