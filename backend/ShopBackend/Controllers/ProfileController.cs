using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.DTOs;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/profile")]
    [Authorize]
    public class ProfileController : ControllerBase
    {
        private readonly AppDbContext _db;

        public ProfileController(AppDbContext db)
        {
            _db = db;
        }

        // ===================== GET PROFILE =====================
        [HttpGet]
        public async Task<IActionResult> GetProfile()
        {
            var userId = GetCurrentUserId();

            if (userId == null)
                return Unauthorized();

            var user = await _db.Users
                .Where(x => x.Id == userId.Value)
                .Select(x => new UserDto
                {
                    Id = x.Id,
                    FullName = x.FullName,
                    Email = x.Email,
                    Avatar = x.Avatar
                })
                .FirstOrDefaultAsync();

            if (user == null)
                return NotFound();

            return Ok(user);
        }

        // ===================== UPDATE PROFILE =====================
        [HttpPut]
        public async Task<IActionResult> UpdateProfile([FromForm] UpdateProfileDto dto)
        {
            var userId = GetCurrentUserId();

            if (userId == null)
                return Unauthorized();

            var user = await _db.Users.FindAsync(userId.Value);

            if (user == null)
                return NotFound();

            // 🔥 update name
            user.FullName = dto.FullName ?? user.FullName;

            // 🔥 upload avatar
            if (dto.Avatar != null)
            {
                var fileName = Guid.NewGuid().ToString() + Path.GetExtension(dto.Avatar.FileName);

                var folderPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/uploads");

                if (!Directory.Exists(folderPath))
                    Directory.CreateDirectory(folderPath);

                var filePath = Path.Combine(folderPath, fileName);

                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await dto.Avatar.CopyToAsync(stream);
                }

                // lưu đường dẫn
                var baseUrl = $"{Request.Scheme}://{Request.Host}";
                user.Avatar = baseUrl + "/uploads/" + fileName;
            }

            await _db.SaveChangesAsync();

            return Ok(new UserDto
            {
                Id = user.Id,
                FullName = user.FullName,
                Email = user.Email,
                Avatar = user.Avatar
            });
        }

        // ===================== GET USER ID =====================
        private int? GetCurrentUserId()
        {
            var claim = User.FindFirst("id");

            if (claim == null)
                return null;

            if (int.TryParse(claim.Value, out var id))
                return id;

            return null;
        }
    }
}