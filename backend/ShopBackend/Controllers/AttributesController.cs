using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.DTOs;
using ShopBackend.Models;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/attributes")]
    public class AttributesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AttributesController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var data = await _context.Attributes
                .Include(a => a.Values)
                .Select(a => new AttributeDto
                {
                    Id = a.Id,
                    Name = a.Name,
                    Values = a.Values.Select(v => v.Value).ToList()
                })
                .ToListAsync();

            return Ok(data);
        }

        [HttpPost]
        public async Task<IActionResult> Create(AttributeDto dto)
        {
            var name = dto.Name?.Trim();
            if (string.IsNullOrWhiteSpace(name))
                return BadRequest("Tên thuộc tính không được để trống");

            var exists = await _context.Attributes.AnyAsync(a => a.Name.ToLower() == name.ToLower());
            if (exists)
                return BadRequest("Thuộc tính đã tồn tại");

            var values = NormalizeValues(dto.Values);
            var attribute = new ProductAttribute
            {
                Name = name,
                Values = values.Select(value => new AttributeValue { Value = value }).ToList()
            };

            _context.Attributes.Add(attribute);
            await _context.SaveChangesAsync();

            return Ok(ToDto(attribute));
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(long id, AttributeDto dto)
        {
            var attribute = await _context.Attributes
                .Include(a => a.Values)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (attribute == null)
                return NotFound();

            var name = dto.Name?.Trim();
            if (string.IsNullOrWhiteSpace(name))
                return BadRequest("Tên thuộc tính không được để trống");

            var duplicated = await _context.Attributes
                .AnyAsync(a => a.Id != id && a.Name.ToLower() == name.ToLower());
            if (duplicated)
                return BadRequest("Thuộc tính đã tồn tại");

            var newValues = NormalizeValues(dto.Values);
            var oldValues = attribute.Values.ToList();
            var oldValueIds = oldValues.Select(v => v.Id).ToList();
            var usedValueIds = await _context.VariantAttributes
                .Where(x => oldValueIds.Contains(x.AttributeValueId))
                .Select(x => x.AttributeValueId)
                .ToListAsync();

            attribute.Name = name;

            foreach (var oldValue in oldValues)
            {
                var stillExists = newValues.Any(v => string.Equals(v, oldValue.Value, StringComparison.OrdinalIgnoreCase));
                if (!stillExists)
                {
                    if (usedValueIds.Contains(oldValue.Id))
                        return BadRequest($"Không thể xóa giá trị '{oldValue.Value}' vì đang được sản phẩm sử dụng");

                    _context.AttributeValues.Remove(oldValue);
                }
            }

            foreach (var value in newValues)
            {
                var exists = oldValues.Any(v => string.Equals(v.Value, value, StringComparison.OrdinalIgnoreCase));
                if (!exists)
                {
                    attribute.Values.Add(new AttributeValue
                    {
                        AttributeId = attribute.Id,
                        Value = value
                    });
                }
            }

            await _context.SaveChangesAsync();

            return Ok(ToDto(attribute));
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(long id)
        {
            var attribute = await _context.Attributes
                .Include(a => a.Values)
                .FirstOrDefaultAsync(a => a.Id == id);

            if (attribute == null)
                return NotFound();

            var valueIds = attribute.Values.Select(v => v.Id).ToList();
            var isUsed = await _context.VariantAttributes.AnyAsync(x => valueIds.Contains(x.AttributeValueId));
            if (isUsed)
                return BadRequest("Không thể xóa thuộc tính đang được sản phẩm sử dụng");

            _context.Attributes.Remove(attribute);
            await _context.SaveChangesAsync();

            return Ok();
        }

        private static List<string> NormalizeValues(List<string>? values)
        {
            return (values ?? new List<string>())
                .Select(v => v.Trim())
                .Where(v => !string.IsNullOrWhiteSpace(v))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();
        }

        private static AttributeDto ToDto(ProductAttribute attribute)
        {
            return new AttributeDto
            {
                Id = attribute.Id,
                Name = attribute.Name,
                Values = attribute.Values.Select(v => v.Value).ToList()
            };
        }
    }
}
