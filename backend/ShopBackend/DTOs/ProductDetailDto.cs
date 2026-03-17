namespace ShopBackend.DTOs
{
    public class ProductDetailDto
    {
        public long Id { get; set; }

        public string Name { get; set; }

        public string Description { get; set; }

        public decimal MinPrice { get; set; }

        public double Rating { get; set; }

        public List<string> Images { get; set; } = new();

        public List<AttributeDto> Attributes { get; set; } = new();

        public List<VariantDto> Variants { get; set; } = new();

        public Dictionary<string, string> ImagesByColor { get; set; } = new();
    }
}
