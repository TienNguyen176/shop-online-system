namespace ShopBackend.DTOs
{
    public class UpsertUserAddressRequest
    {
        public string ReceiverName { get; set; } = "";
        public string Phone { get; set; } = "";
        public string AddressLine { get; set; } = "";
        public int ProvinceId { get; set; }
        public string ProvinceName { get; set; } = "";
        public int DistrictId { get; set; }
        public string DistrictName { get; set; } = "";
        public string WardCode { get; set; } = "";
        public string WardName { get; set; } = "";
        public bool IsDefault { get; set; }
    }
}
