namespace ShopBackend.DTOs
{
    public class AddToCartDto
    {
        public long UserId { get; set; }
        public int ProductId { get; set; }
        public int VariantId { get; set; }
        public int Quantity { get; set; }
    }
}
