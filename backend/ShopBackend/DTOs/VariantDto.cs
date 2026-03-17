namespace ShopBackend.DTOs
{
    public class VariantDto
    {
        public long VariantId { get; set; }

        public decimal Price { get; set; }

        public int Stock { get; set; }

        public Dictionary<string, string> Attributes { get; set; }
    }
}
