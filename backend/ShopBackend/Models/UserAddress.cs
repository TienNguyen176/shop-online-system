using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    [Table("user_addresses")]
    public class UserAddress
    {
        public long Id { get; set; }

        [Column("user_id")]
        public long UserId { get; set; }

        [Column("receiver_name")]
        public string? ReceiverName { get; set; }

        [Column("phone")]
        public string? Phone { get; set; }

        [Column("address_line")]
        public string? AddressLine { get; set; }

        [Column("province_id")]
        public int? ProvinceId { get; set; }

        [Column("province_name")]
        public string? ProvinceName { get; set; }

        [Column("district_id")]
        public int? DistrictId { get; set; }

        [Column("district_name")]
        public string? DistrictName { get; set; }

        [Column("ward_code")]
        public string? WardCode { get; set; }

        [Column("ward_name")]
        public string? WardName { get; set; }

        [Column("is_default")]
        public bool IsDefault { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
