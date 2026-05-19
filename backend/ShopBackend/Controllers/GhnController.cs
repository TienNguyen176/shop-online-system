using System.Text.Json;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShopBackend.DTOs;
using System.Net.Http.Json;

namespace ShopBackend.Controllers
{
    [ApiController]
    [Authorize]
    [Route("api/ghn")]
    public class GhnController : ControllerBase
    {
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _config;

        public GhnController(IHttpClientFactory httpClientFactory, IConfiguration config)
        {
            _httpClientFactory = httpClientFactory;
            _config = config;
        }

        [HttpGet("provinces")]
        public async Task<IActionResult> Provinces()
        {
            var data = await GetGhnData("/master-data/province");
            var result = data.EnumerateArray()
                .Select(x => new GhnLocationDto
                {
                    Id = x.GetProperty("ProvinceID").GetInt32().ToString(),
                    Name = x.GetProperty("ProvinceName").GetString() ?? ""
                })
                .OrderBy(x => x.Name)
                .ToList();

            return Ok(result);
        }

        [HttpGet("districts")]
        public async Task<IActionResult> Districts([FromQuery] int provinceId)
        {
            var data = await GetGhnData($"/master-data/district?province_id={provinceId}");
            var result = data.EnumerateArray()
                .Select(x => new GhnLocationDto
                {
                    Id = x.GetProperty("DistrictID").GetInt32().ToString(),
                    Name = x.GetProperty("DistrictName").GetString() ?? ""
                })
                .OrderBy(x => x.Name)
                .ToList();

            return Ok(result);
        }

        [HttpGet("wards")]
        public async Task<IActionResult> Wards([FromQuery] int districtId)
        {
            var data = await GetGhnData($"/master-data/ward?district_id={districtId}");
            var result = data.EnumerateArray()
                .Select(x => new GhnLocationDto
                {
                    Id = x.GetProperty("WardCode").GetString() ?? "",
                    Name = x.GetProperty("WardName").GetString() ?? ""
                })
                .OrderBy(x => x.Name)
                .ToList();

            return Ok(result);
        }

        [HttpGet("shipping-fee")]
        public async Task<IActionResult> ShippingFee(
            [FromQuery] int toDistrictId,
            [FromQuery] string toWardCode,
            [FromQuery] double insuranceValue = 0,
            [FromQuery] int quantity = 1)
        {
            var fallbackFee = _config.GetValue<double>("GHN:DefaultShippingFee", 30000);
            var token = _config["GHN:Token"];
            var shopId = _config.GetValue<int>("GHN:ShopId");
            var fromDistrictId = _config.GetValue<int>("GHN:FromDistrictId");

            if (string.IsNullOrWhiteSpace(token) ||
                shopId <= 0 ||
                fromDistrictId <= 0 ||
                toDistrictId <= 0 ||
                string.IsNullOrWhiteSpace(toWardCode))
            {
                return Ok(new { fee = fallbackFee, source = "fallback" });
            }

            var baseUrl = _config["GHN:BaseUrl"] ?? "https://online-gateway.ghn.vn/shiip/public-api";
            var client = _httpClientFactory.CreateClient();
            var request = new HttpRequestMessage(
                HttpMethod.Post,
                $"{baseUrl}/v2/shipping-order/fee");

            request.Headers.Add("Token", token);
            request.Headers.Add("ShopId", shopId.ToString());
            request.Content = JsonContent.Create(new
            {
                service_type_id = _config.GetValue<int>("GHN:ServiceTypeId", 2),
                insurance_value = Math.Max(0, (int)Math.Round(insuranceValue)),
                from_district_id = fromDistrictId,
                to_district_id = toDistrictId,
                to_ward_code = toWardCode,
                height = _config.GetValue<int>("GHN:DefaultHeightCm", 10),
                length = _config.GetValue<int>("GHN:DefaultLengthCm", 20),
                weight = _config.GetValue<int>("GHN:DefaultWeightGram", 500) * Math.Max(1, quantity),
                width = _config.GetValue<int>("GHN:DefaultWidthCm", 15)
            });

            try
            {
                var response = await client.SendAsync(request);
                response.EnsureSuccessStatusCode();

                var json = await response.Content.ReadAsStringAsync();
                using var document = JsonDocument.Parse(json);
                var fee = document.RootElement
                    .GetProperty("data")
                    .GetProperty("total")
                    .GetDouble();

                return Ok(new { fee, source = "ghn" });
            }
            catch
            {
                return Ok(new { fee = fallbackFee, source = "fallback" });
            }
        }

        private async Task<JsonElement> GetGhnData(string path)
        {
            var token = _config["GHN:Token"];
            if (string.IsNullOrWhiteSpace(token))
            {
                throw new InvalidOperationException("GHN token is not configured");
            }

            var baseUrl = _config["GHN:BaseUrl"] ?? "https://online-gateway.ghn.vn/shiip/public-api";
            var client = _httpClientFactory.CreateClient();
            var request = new HttpRequestMessage(HttpMethod.Get, $"{baseUrl}{path}");
            request.Headers.Add("Token", token);

            var response = await client.SendAsync(request);
            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadAsStringAsync();
            using var document = JsonDocument.Parse(json);
            return document.RootElement.GetProperty("data").Clone();
        }
    }
}
