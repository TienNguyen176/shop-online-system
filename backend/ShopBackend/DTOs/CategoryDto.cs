namespace ShopBackend.DTOs
{
    public class CategoryDto
    {
        public long Id { get; set; }

        public string Name { get; set; }

        public string Slug { get; set; }

        public string? Image { get; set; }

        public List<CategoryDto> Children { get; set; } = new();

    }
}
