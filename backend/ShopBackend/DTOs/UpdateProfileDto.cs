using Microsoft.AspNetCore.Http;

namespace ShopBackend.DTOs
{
    public class UpdateProfileDto
    {
        public string? FullName { get; set; }
        public IFormFile? Avatar { get; set; } // 🔥 phải là file
    }
}