using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.DTOs;
using ShopBackend.Models;
using ShopBackend.Services;
namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly AuthService _auth;

        public AuthController(AuthService auth)
        {
            _auth = auth;
        }

        [HttpPost("social-login")]
        public async Task<IActionResult> SocialLogin(SocialLoginRequest req)
        {
            var res = await _auth.SocialLogin(req.Provider, req.Token);

            if (res == null) return BadRequest();

            return Ok(res);
        }
    }
}
