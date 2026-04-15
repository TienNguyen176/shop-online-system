using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    public class Payment
    {
        public long Id { get; set; }

        [Column("order_id")]
        public long OrderId { get; set; }

        [Column("payment_method_id")]
        public int PaymentMethodId { get; set; } // VNPAY / MOMO

        [Column("transaction_id")]
        public string TransactionId { get; set; }

        public decimal Amount { get; set; }

        public string Status { get; set; } = "PENDING";


        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}