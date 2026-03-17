using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    [Table("attribute_values")]
    public class AttributeValue
    {
        [Key]
        public long Id { get; set; }

        [Column("attribute_id")]
        public long AttributeId { get; set; }

        public string Value { get; set; }

        public ProductAttribute Attribute { get; set; }

<<<<<<< HEAD
       

=======
>>>>>>> 4d9c391 (apply new gitignore rules)
    }
}
