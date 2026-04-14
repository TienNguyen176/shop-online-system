using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    [Table("carts")]
    public class Cart
    {
        [Key]
        public long Id { get; set; }

        [Column("user_id")]
<<<<<<< HEAD
        public int UserId { get; set; }
=======
        public long UserId { get; set; }
>>>>>>> b0bf4c1 (15/4: Function CartItem (Add, Delete))
    }
}