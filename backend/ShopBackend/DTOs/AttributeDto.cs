namespace ShopBackend.DTOs
{
    public class AttributeDto
    {

        public long? Id { get; set; }

        public string Name { get; set; } = string.Empty;

        public List<string> Values { get; set; } = new();
    }
}
