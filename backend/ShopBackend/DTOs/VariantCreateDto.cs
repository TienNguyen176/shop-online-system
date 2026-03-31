using System.Collections.Generic;

namespace ShopBackend.DTOs
{
    public class VariantCreateDto
    {
        public decimal Price { get; set; }

        public string? Sku { get; set; }

        public int StockQuantity { get; set; }

        public Dictionary<string, string>? Attributes { get; set; }
    }
}