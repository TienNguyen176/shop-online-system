namespace ShopBackend.DTOs
{
    public class OrderItemDto
    {
        public long ProductId { get; set; }
        public long VariantId { get; set; }

        public string ProductName { get; set; }
        public string VariantName { get; set; }

        public int Quantity { get; set; }

        public decimal Price { get; set; }
    }
}