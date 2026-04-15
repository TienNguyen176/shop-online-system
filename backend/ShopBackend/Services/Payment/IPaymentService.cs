using ShopBackend.Models;

namespace ShopBackend.Services.Payment
{
    public interface IPaymentService
    {
        string CreatePaymentUrl(Order order, string ipAddress);
    }
}