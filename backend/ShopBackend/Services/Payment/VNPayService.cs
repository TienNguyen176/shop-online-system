using Microsoft.Extensions.Options;
using ShopBackend.Models;
using System.Globalization;
using System.Net;
using System.Security.Cryptography;
using System.Text;

namespace ShopBackend.Services.Payment
{
    public class VNPayService
    {
        private readonly VnpayOptions _config;

        public VNPayService(IOptions<VnpayOptions> config)
        {
            _config = config.Value;
        }

        public string CreatePaymentUrl(Order order, string ipAddress)
        {
            var vnpParams = new SortedDictionary<string, string>();

            long amount = (long)(order.TotalPrice * 100);

            vnpParams.Add("vnp_Version", _config.Version);
            vnpParams.Add("vnp_Command", "pay");
            vnpParams.Add("vnp_TmnCode", _config.TmnCode);
            vnpParams.Add("vnp_Amount", amount.ToString());
            vnpParams.Add("vnp_CurrCode", "VND");
            vnpParams.Add("vnp_TxnRef", order.OrderCode);
            vnpParams.Add("vnp_OrderInfo", $"Thanh toan don hang {order.OrderCode}");
            vnpParams.Add("vnp_OrderType", _config.OrderType);
            vnpParams.Add("vnp_Locale", "vn");

            vnpParams.Add("vnp_ReturnUrl", _config.ReturnUrl);
            vnpParams.Add("vnp_IpAddr", FixIp(ipAddress));

            vnpParams.Add("vnp_CreateDate", GetVNTime());
            vnpParams.Add("vnp_ExpireDate", GetVNTimePlusMinutes(15));

            // BUILD QUERY + HASH
            var signData = string.Join("&", vnpParams.Select(x => $"{x.Key}={x.Value}"));
            var secureHash = HmacSHA512(_config.HashSecret, signData);

            var query = new StringBuilder();

            foreach (var item in vnpParams)
            {
                query.Append($"{item.Key}={WebUtility.UrlEncode(item.Value)}&");
            }

            query.Append($"vnp_SecureHash={secureHash}");

            return _config.BaseUrl + "?" + query;
        }

        public bool ValidateReturn(IQueryCollection query)
        {
            var vnpData = query.ToDictionary(x => x.Key, x => x.Value.ToString());

            var secureHash = vnpData["vnp_SecureHash"];
            vnpData.Remove("vnp_SecureHash");
            vnpData.Remove("vnp_SecureHashType");

            var signData = string.Join("&",
                vnpData.OrderBy(x => x.Key)
                       .Select(x => $"{x.Key}={x.Value}")
            );

            var checkHash = HmacSHA512(_config.HashSecret, signData);

            return checkHash.Equals(secureHash, StringComparison.OrdinalIgnoreCase);
        }

        private string HmacSHA512(string key, string data)
        {
            using var hmac = new HMACSHA512(Encoding.UTF8.GetBytes(key));
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(data));
            return BitConverter.ToString(hash).Replace("-", "").ToLower();
        }

        private string GetVNTime()
        {
            return TimeZoneInfo.ConvertTimeBySystemTimeZoneId(
                DateTime.UtcNow,
                "SE Asia Standard Time"
            ).ToString("yyyyMMddHHmmss");
        }

        private string GetVNTimePlusMinutes(int min)
        {
            return TimeZoneInfo.ConvertTimeBySystemTimeZoneId(
                DateTime.UtcNow.AddMinutes(min),
                "SE Asia Standard Time"
            ).ToString("yyyyMMddHHmmss");
        }

        private string FixIp(string ip)
        {
            if (string.IsNullOrEmpty(ip)) return "127.0.0.1";
            if (ip.Contains(":")) return "127.0.0.1";
            return ip;
        }
    }
}