using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    [Table("payment_methods")]
    public class PaymentMethod
    {
        public int Id { get; set; }

        public required string Name { get; set; }
    }
}