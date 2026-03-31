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

        /// =========================
        /// GET ALL
        /// =========================
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

        /// =========================
        /// CREATE
        /// =========================
        //[HttpPost]
        //public async Task<IActionResult> Create(CreateAttributeDto dto)
        //{
        //    var attribute = new Attribute
        //    {
        //        Name = dto.Name,
        //        Values = dto.Values.Select(v => new AttributeValue
        //        {
        //            Value = v
        //        }).ToList()
        //    };

        //    _context.Attributes.Add(attribute);
        //    await _context.SaveChangesAsync();

        //    return Ok();
        //}

        /// =========================
        /// UPDATE
        /// =========================
        //[HttpPut("{id}")]
        //public async Task<IActionResult> Update(int id, CreateAttributeDto dto)
        //{
        //    var attribute = await _context.Attributes
        //        .Include(a => a.Values)
        //        .FirstOrDefaultAsync(a => a.Id == id);

        //    if (attribute == null)
        //        return NotFound();

        //    attribute.Name = dto.Name;

        //    /// clear old values
        //    _context.AttributeValues.RemoveRange(attribute.Values);

        //    /// add new values
        //    attribute.Values = dto.Values.Select(v => new AttributeValue
        //    {
        //        Value = v
        //    }).ToList();

        //    await _context.SaveChangesAsync();

        //    return Ok();
        //}

        /// =========================
        /// DELETE
        /// =========================
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            var attribute = await _context.Attributes.FindAsync(id);

            if (attribute == null)
                return NotFound();

            _context.Attributes.Remove(attribute);
            await _context.SaveChangesAsync();

            return Ok();
        }
    }
}
