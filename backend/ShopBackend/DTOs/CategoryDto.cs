namespace ShopBackend.DTOs
{
    public class CategoryDto
    {
        public long Id { get; set; }

        public string Name { get; set; } = string.Empty;

        public string Slug { get; set; } = string.Empty;

        public string? Image { get; set; }

        public long? ParentId { get; set; }

        public int Level { get; set; }

        public List<CategoryDto> Children { get; set; } = new();

    }
}
