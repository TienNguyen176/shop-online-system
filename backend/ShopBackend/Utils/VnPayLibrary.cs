using System.Globalization;
using System.Net;
using System.Security.Cryptography;
using System.Text;

namespace ShopBackend.Utils
{
    public class VnPayLibrary
    {
        private SortedList<string, string> _requestData = new(new VnPayCompare());
        private SortedList<string, string> _responseData = new(new VnPayCompare());

        public void AddRequestData(string key, string value)
        {
            if (!string.IsNullOrEmpty(value))
                _requestData.Add(key, value);
        }

        public void AddResponseData(string key, string value)
        {
            if (!string.IsNullOrEmpty(value))
                _responseData.Add(key, value);
        }

        public string GetResponseData(string key)
        {
            return _responseData.TryGetValue(key, out var value) ? value : "";
        }

        // ================= CREATE URL =================
        public string CreateRequestUrl(string baseUrl, string hashSecret)
        {
            // 1. Build RAW string for hash (KHÔNG encode)
            StringBuilder data = new StringBuilder();

            foreach (var kv in _requestData)
            {
                if (!string.IsNullOrEmpty(kv.Value))
                {
                    data.Append($"{kv.Key}={kv.Value}&");
                }
            }

            string rawData = data.ToString().TrimEnd('&');

            // 2. Generate signature
            string secureHash = HmacSHA512(hashSecret, rawData);

            // 3. Build URL (THIS PART MUST BE ENCODED)
            StringBuilder query = new StringBuilder();

            foreach (var kv in _requestData)
            {
                if (!string.IsNullOrEmpty(kv.Value))
                {
                    query.Append($"{kv.Key}={WebUtility.UrlEncode(kv.Value)}&");
                }
            }

            query.Append($"vnp_SecureHash={secureHash}");

            return baseUrl + "?" + query;
        }

        // ================= VALIDATE RESPONSE =================
        public bool ValidateSignature(string inputHash, string secretKey)
        {
            string rawData = GetResponseRaw();

            string myHash = HmacSHA512(secretKey, rawData);

            return myHash.Equals(inputHash, StringComparison.OrdinalIgnoreCase);
        }

        private string GetResponseRaw()
        {
            StringBuilder data = new StringBuilder();

            var filtered = _responseData
                .Where(x => x.Key != "vnp_SecureHash" && x.Key != "vnp_SecureHashType");

            foreach (var kv in filtered)
            {
                data.Append($"{kv.Key}={kv.Value}&");
            }

            return data.ToString().TrimEnd('&');
        }

        private string HmacSHA512(string key, string inputData)
        {
            using var hmac = new HMACSHA512(Encoding.UTF8.GetBytes(key));
            var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(inputData));

            return BitConverter.ToString(hash).Replace("-", "").ToLower();
        }

        public class VnPayCompare : IComparer<string>
        {
            public int Compare(string x, string y)
            {
                if (x == y) return 0;
                if (x == null) return -1;
                if (y == null) return 1;
                var vnpCompare = CompareInfo.GetCompareInfo("en-US");
                return vnpCompare.Compare(x, y, CompareOptions.Ordinal);
            }
        }
    }
}