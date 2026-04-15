namespace ShopBackend.DTOs
{
    public class PaymentRequest
    {
        public long OrderId { get; set; }
        public string Method { get; set; } // VNPAY / MOMO
    }
}