using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    public class Payment
    {
        public long Id { get; set; }

        [Column("order_id")]
        public long OrderId { get; set; }

        [Column("payment_method_id")]
        public int PaymentMethodId { get; set; } // 2 = VNPAY

        [Column("transaction_id")]
        public string TransactionId { get; set; }

        [Column("amount")]
        public decimal Amount { get; set; }

        public string Status { get; set; } = "PENDING";

        // ADD IMPORTANT FIELDS
        [Column("vnp_response_code")]
        public string VnpResponseCode { get; set; }

        [Column("bank_code")]
        public string BankCode { get; set; }

        [Column("paid_at")]
        public DateTime? PaidAt { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;

        // NAVIGATION
        public Order Order { get; set; }
    }
}