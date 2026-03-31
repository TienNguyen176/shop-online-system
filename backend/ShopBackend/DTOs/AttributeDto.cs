namespace ShopBackend.DTOs
{
    public class AttributeDto
    {

        public long? Id { get; set; }

        public string Name { get; set; }

        public List<string> Values { get; set; }
    }
}
