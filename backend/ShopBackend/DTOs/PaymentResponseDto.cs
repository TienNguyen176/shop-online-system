namespace ShopBackend.DTOs
{
    public class PaymentResponse
    {
        public long OrderId { get; set; }
        public required string PaymentUrl { get; set; }
    }
}