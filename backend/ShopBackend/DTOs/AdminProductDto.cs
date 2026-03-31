using System.Collections.Generic;

namespace ShopBackend.DTOs
{
    public class AdminProductDto
    {
        public string Name { get; set; } = default!;

        public string? Description { get; set; }

        public long? CategoryId { get; set; }

        public string? Brand { get; set; }

        public List<VariantCreateDto> Variants { get; set; } = new();

        public List<ImageCreateDto>? Images { get; set; }
    }
}