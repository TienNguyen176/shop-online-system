using ShopBackend.Models;

namespace ShopBackend.DTOs
{
    public class CheckoutRequest
    {
        public int UserId { get; set; }
        public decimal TotalPrice { get; set; }
        public required string ShippingName { get; set; }
        public required string ShippingPhone { get; set; }
        public required string ShippingAddress { get; set; }
        public int PaymentMethodId { get; set; }

        public List<OrderItem> Items { get; set; }
    }
}