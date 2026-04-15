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

        public List<CheckoutItem> Items { get; set; }
    }

    public class CheckoutItem
    {
        public int ProductId { get; set; }
        public int VariantId { get; set; }
        public int Quantity { get; set; }
        public decimal Price { get; set; }
    }
}