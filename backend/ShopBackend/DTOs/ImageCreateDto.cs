namespace ShopBackend.DTOs
{
    public class ImageCreateDto
    {
        public string ImageUrl { get; set; } = default!;

        public bool IsMain { get; set; }

        public int? VariantIndex { get; set; }
    }
}