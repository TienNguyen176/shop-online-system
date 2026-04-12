using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.DTOs;
using ShopBackend.Models;
using Google.Apis.Auth;
using System.Text.Json;

namespace ShopBackend.Services
{
    public class AuthService
    {
        private readonly AppDbContext _db;
        private readonly JwtService _jwt;

        public AuthService(AppDbContext db, JwtService jwt)
        {
            _db = db;
            _jwt = jwt;
        }

        public async Task<AuthResponse?> SocialLogin(string provider, string token)
        {
            SocialUserInfo info;

            if (provider == "google")
            {
                info = await VerifyGoogle(token);
            }
            else if (provider == "facebook")
            {
                info = await VerifyFacebook(token);
            }
            else
            {
                throw new Exception("Invalid provider");
            }

            var user = await _db.Users.FirstOrDefaultAsync(x =>
                x.Provider == provider &&
                x.ProviderUserId == info.Id);

            if (user == null)
            {
                user = new User
                {
                    Provider = provider,
                    ProviderUserId = info.Id,
                    Email = info.Email,
                    FullName = info.Name,
                    Avatar = info.Picture,
                    Role = "user",
                    CreatedAt = DateTime.UtcNow
                };

                _db.Users.Add(user);
                await _db.SaveChangesAsync();
            }

            return await GenerateAuth(user);
        }

        // ================= GOOGLE =================
        private async Task<SocialUserInfo> VerifyGoogle(string token)
        {
            var payload = await GoogleJsonWebSignature.ValidateAsync(token);

            return new SocialUserInfo
            {
                Id = payload.Subject,
                Email = payload.Email,
                Name = payload.Name,
                Picture = payload.Picture
            };
        }

        // ================= FACEBOOK =================
        private async Task<SocialUserInfo> VerifyFacebook(string token)
        {
            using var http = new HttpClient();

            var res = await http.GetAsync(
                $"https://graph.facebook.com/me?fields=id,name,email,picture&access_token={token}"
            );

            if (!res.IsSuccessStatusCode)
                throw new Exception("Invalid Facebook token");

            var json = await res.Content.ReadAsStringAsync();
            var data = JsonDocument.Parse(json).RootElement;

            var id = data.GetProperty("id").GetString() ?? "";
            var name = data.GetProperty("name").GetString() ?? "";

            var email = data.TryGetProperty("email", out var e)
                ? e.GetString()
                : $"{id}@facebook.com";

            string? picture = null;

            if (data.TryGetProperty("picture", out var pic))
            {
                picture = pic
                    .GetProperty("data")
                    .GetProperty("url")
                    .GetString();
            }

            return new SocialUserInfo
            {
                Id = id,
                Email = email ?? "",
                Name = name,
                Picture = picture
            };
        }

        // ================= GENERATE TOKEN =================
        private async Task<AuthResponse> GenerateAuth(User user)
        {
            var access = _jwt.GenerateAccessToken(user);
            var refresh = _jwt.GenerateRefreshToken();

            _db.RefreshTokens.Add(new RefreshToken
            {
                UserId = user.Id,
                Token = refresh,
                ExpiresAt = DateTime.UtcNow.AddDays(7)
            });

            await _db.SaveChangesAsync();

            return new AuthResponse
            {
                AccessToken = access,
                RefreshToken = refresh,
                User = user
            };
        }
    }
}