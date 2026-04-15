using ShopBackend.Models;
using ShopBackend.Utils;

namespace ShopBackend.Services.Payment
{
    public class VNPayService : IPaymentService
    {
        private readonly string vnp_Url = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
        private readonly string vnp_TmnCode = "3V73MVZ1";
        private readonly string vnp_HashSecret = "LJS0H5H6POWRN0A80PBRTNMFPPGLPD5J";

        public string CreatePaymentUrl(Order order, string ipAddress)
        {
            var vnpay = new VnPayLibrary();

            // ======================
            // FIX IP (production-safe)
            // ======================
            if (string.IsNullOrEmpty(ipAddress) ||
                ipAddress.StartsWith("::1") ||
                ipAddress.Contains(":") ||
                ipAddress.StartsWith("192.") ||
                ipAddress.StartsWith("10.") ||
                ipAddress.StartsWith("127."))
            {
                ipAddress = "127.0.0.1";
            }

            // ======================
            // VNPay requires amount * 100
            // ======================
            long amount = Convert.ToInt64(order.TotalPrice * 100);

            // ======================
            // REQUEST DATA (A-Z SORT WILL BE HANDLED BY LIB)
            // ======================
            vnpay.AddRequestData("vnp_Amount", amount.ToString());
            vnpay.AddRequestData("vnp_Command", "pay");
            vnpay.AddRequestData("vnp_CreateDate", DateTime.Now.ToString("yyyyMMddHHmmss"));
            vnpay.AddRequestData("vnp_CurrCode", "VND");
            vnpay.AddRequestData("vnp_IpAddr", ipAddress);
            vnpay.AddRequestData("vnp_Locale", "vn");

            vnpay.AddRequestData(
                "vnp_OrderInfo",
                $"Thanh toan don hang {order.OrderCode}"
            );

            vnpay.AddRequestData("vnp_ReturnUrl", "https://shopapp.ddns.net/payment/vnpay-return");
            vnpay.AddRequestData("vnp_TmnCode", vnp_TmnCode);

            vnpay.AddRequestData("vnp_TxnRef", order.OrderCode);
            vnpay.AddRequestData("vnp_Version", "2.1.0");

            // ======================
            // DEBUG (optional - remove in production)
            // ======================
            Console.WriteLine($"ORDER: {order.TotalPrice}");
            Console.WriteLine($"AMOUNT: {amount}");

            var url = vnpay.CreateRequestUrl(vnp_Url, vnp_HashSecret);

            Console.WriteLine($"VNPay URL: {url}");

            return url;
        }
    }
}