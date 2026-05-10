using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShopBackend.Data;
using ShopBackend.DTOs;

namespace ShopBackend.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StatisticController : ControllerBase
    {
        private readonly AppDbContext _context;

        public StatisticController(AppDbContext context)
        {
            _context = context;
        }

   [HttpGet]
public async Task<IActionResult> GetStatistic()
{
    var data = await (
        from item in _context.OrderItems
        join order in _context.Orders
            on item.OrderId equals order.Id

        group item by item.ProductName into g

        select new
        {
            ProductName = g.Key,
            Revenue = g.Sum(x => x.Quantity * x.Price)
        }

    ).ToListAsync();

    var totalRevenue = data.Sum(x => x.Revenue);

    var result = data.Select(item => new StatisticDto
    {
        Title = item.ProductName,
        Percent = totalRevenue == 0
            ? 0
            : (int)Math.Round((item.Revenue / totalRevenue) * 100)
    }).ToList();

    return Ok(result);
}
}
}