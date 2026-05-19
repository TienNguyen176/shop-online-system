
namespace ShopBackend.Models.Vnpay
{
    public class PaymentInformationModel
    {
        public long OrderId { get; set; }

        public string OrderType { get; set; }

        public long UserId { get; set; }

        public double Amount { get; set; }

        public string OrderDescription { get; set; }

        public string Name { get; set; }

        public string Phone { get; set; }

        public string Address { get; set; }

        public List<OrderItem> Items { get; set; }
    }
}
