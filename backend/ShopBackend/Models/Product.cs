namespace ShopBackend.Models
{
    public class Product
    {
        public int Id { get; set; }

        public string Name { get; set; }

        public string Description { get; set; }

        public decimal Price { get; set; }

        public string Image { get; set; }

        public bool IsHot { get; set; }

        public DateTime CreatedAt { get; set; }

    }
}
