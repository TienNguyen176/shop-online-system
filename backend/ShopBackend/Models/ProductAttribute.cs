using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    [Table("attributes")]
    public class ProductAttribute
    {
        [Key]
        public long Id { get; set; }

        public string Name { get; set; }

    }
}
