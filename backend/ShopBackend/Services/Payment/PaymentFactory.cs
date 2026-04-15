using ShopBackend.Models;

namespace ShopBackend.Services.Payment
{
    public class PaymentFactory
    {
        private readonly VNPayService _vnpay;
        private readonly MoMoService _momo;

        public PaymentFactory(VNPayService vnpay, MoMoService momo)
        {
            _vnpay = vnpay;
            _momo = momo;
        }

        public string Create(Order order, int method, string ip)
        {
            return method switch
            {
                1 => "COD", // Cash on Delivery, no URL needed
                2 => _vnpay.CreatePaymentUrl(order, ip),
                3 => _momo.CreatePaymentUrl(order, ip),
                _ => throw new Exception("Invalid payment method")
            };
        }
    }
}