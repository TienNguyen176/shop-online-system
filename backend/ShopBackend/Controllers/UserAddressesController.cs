using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.DTOs;
using ShopBackend.Models;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/user-addresses")]
    public class UserAddressesController : ControllerBase
    {
        private readonly AppDbContext _db;

        public UserAddressesController(AppDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<IActionResult> GetAddresses()
        {
            var userId = CurrentUserId();
            if (userId == null) return Unauthorized();

            var addresses = await _db.UserAddresses
                .Where(x => x.UserId == userId.Value)
                .OrderByDescending(x => x.IsDefault)
                .ThenByDescending(x => x.Id)
                .ToListAsync();

            return Ok(addresses.Select(ToDto).ToList());
        }

        [HttpPost]
        public async Task<IActionResult> CreateAddress([FromBody] UpsertUserAddressRequest request)
        {
            var userId = CurrentUserId();
            if (userId == null) return Unauthorized();

            var address = new UserAddress
            {
                UserId = userId.Value,
                CreatedAt = DateTime.Now
            };

            Apply(address, request);
            _db.UserAddresses.Add(address);

            if (address.IsDefault)
            {
                await ClearDefault(userId.Value, exceptId: null);
            }

            await _db.SaveChangesAsync();
            return Ok(ToDto(address));
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateAddress(long id, [FromBody] UpsertUserAddressRequest request)
        {
            var userId = CurrentUserId();
            if (userId == null) return Unauthorized();

            var address = await _db.UserAddresses
                .FirstOrDefaultAsync(x => x.Id == id && x.UserId == userId.Value);

            if (address == null) return NotFound();

            Apply(address, request);

            if (address.IsDefault)
            {
                await ClearDefault(userId.Value, address.Id);
            }

            await _db.SaveChangesAsync();
            return Ok(ToDto(address));
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAddress(long id)
        {
            var userId = CurrentUserId();
            if (userId == null) return Unauthorized();

            var address = await _db.UserAddresses
                .FirstOrDefaultAsync(x => x.Id == id && x.UserId == userId.Value);

            if (address == null) return NotFound();

            _db.UserAddresses.Remove(address);
            await _db.SaveChangesAsync();
            return Ok(new { message = "Deleted" });
        }

        private long? CurrentUserId()
        {
            var value = User.FindFirst("id")?.Value;
            return long.TryParse(value, out var userId) ? userId : null;
        }

        private async Task ClearDefault(long userId, long? exceptId)
        {
            var addresses = await _db.UserAddresses
                .Where(x => x.UserId == userId && (!exceptId.HasValue || x.Id != exceptId.Value))
                .ToListAsync();

            foreach (var item in addresses)
            {
                item.IsDefault = false;
            }
        }

        private static void Apply(UserAddress address, UpsertUserAddressRequest request)
        {
            address.ReceiverName = request.ReceiverName.Trim();
            address.Phone = request.Phone.Trim();
            address.AddressLine = request.AddressLine.Trim();
            address.ProvinceId = request.ProvinceId;
            address.ProvinceName = request.ProvinceName.Trim();
            address.DistrictId = request.DistrictId;
            address.DistrictName = request.DistrictName.Trim();
            address.WardCode = request.WardCode.Trim();
            address.WardName = request.WardName.Trim();
            address.IsDefault = request.IsDefault;
        }

        private static UserAddressDto ToDto(UserAddress address)
        {
            var parts = new[]
            {
                address.AddressLine,
                address.WardName,
                address.DistrictName,
                address.ProvinceName
            }.Where(x => !string.IsNullOrWhiteSpace(x));

            return new UserAddressDto
            {
                Id = address.Id,
                ReceiverName = address.ReceiverName ?? "",
                Phone = address.Phone ?? "",
                AddressLine = address.AddressLine ?? "",
                ProvinceId = address.ProvinceId,
                ProvinceName = address.ProvinceName ?? "",
                DistrictId = address.DistrictId,
                DistrictName = address.DistrictName ?? "",
                WardCode = address.WardCode ?? "",
                WardName = address.WardName ?? "",
                IsDefault = address.IsDefault,
                FullAddress = string.Join(", ", parts)
            };
        }
    }
}
