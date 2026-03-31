using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    [Table("variant_attributes")]
    public class VariantAttribute
    {
    [Column("variant_id")]
    public long VariantId { get; set; }

    [Column("attribute_value_id")]
    public long AttributeValueId { get; set; }

    public ProductVariant Variant { get; set; } // dùng property này

    public AttributeValue AttributeValue { get; set; }
    }
}

