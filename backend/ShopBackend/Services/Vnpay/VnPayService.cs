using ShopBackend.Libraries;
using ShopBackend.Models.Vnpay;

namespace ShopBackend.Services.Vnpay
{
    public class VnPayService : IVnPayService
    {
        private readonly IConfiguration _configuration;

        public VnPayService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public string CreatePaymentUrl(PaymentInformationModel model, HttpContext context)
        {
            var timeZoneById = TimeZoneInfo.FindSystemTimeZoneById(_configuration["TimeZoneId"]);

            var now = DateTime.UtcNow;
            var timeNow = TimeZoneInfo.ConvertTimeFromUtc(now, timeZoneById);
            var tick = now.Ticks.ToString();

            var pay = new VnPayLibrary();

            var urlCallBack = _configuration["VNPAY:PaymentBackReturnUrl"];

            pay.AddRequestData("vnp_Version", _configuration["VNPAY:Version"]);
            pay.AddRequestData("vnp_Command", _configuration["VNPAY:Command"]);
            pay.AddRequestData("vnp_TmnCode", _configuration["VNPAY:TmnCode"]);

            pay.AddRequestData("vnp_Amount", ((long)(model.Amount * 100)).ToString());

            pay.AddRequestData("vnp_CreateDate", timeNow.ToString("yyyyMMddHHmmss"));
            pay.AddRequestData("vnp_CurrCode", _configuration["VNPAY:CurrCode"]);
            pay.AddRequestData("vnp_IpAddr", pay.GetIpAddress(context));
            pay.AddRequestData("vnp_Locale", _configuration["VNPAY:Locale"]);

            pay.AddRequestData("vnp_OrderInfo",
                $"{model.Name} {model.OrderDescription} {model.Amount}");

            pay.AddRequestData("vnp_OrderType", model.OrderType);

            pay.AddRequestData("vnp_ReturnUrl", urlCallBack);

            pay.AddRequestData("vnp_TxnRef", tick);

            return pay.CreateRequestUrl(
                _configuration["VNPAY:BaseUrl"],
                _configuration["VNPAY:HashSecret"]
            );
        }

        public PaymentResponseModel PaymentExecute(IQueryCollection collections)
        {
            var pay = new VnPayLibrary();
            var response = pay.GetFullResponseData(collections, _configuration["VNPAY:HashSecret"]);

            return response;
        }
    }
}