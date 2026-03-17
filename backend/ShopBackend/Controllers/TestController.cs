using Microsoft.AspNetCore.Mvc;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Route("api/test")]
    public class TestController : ControllerBase
    {
        [HttpGet]
        public string Get()
        {
            return "Server Running OK";
        }
    }
}
