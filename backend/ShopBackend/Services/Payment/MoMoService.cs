using ShopBackend.Models;

namespace ShopBackend.Services.Payment
{
    public class MoMoService
    {
        public string CreatePaymentUrl(Order order, string ipAddress)
        {
            string endpoint = "https://test-payment.momo.vn/v2/gateway/api/create";

            // build request
            // sign signature
            // call API

            return "https://momo-payment-url";
        }
    }
}