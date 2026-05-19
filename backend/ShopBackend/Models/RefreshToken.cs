using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    [Table("refresh_tokens")]
    public class RefreshToken
    {
        public int Id { get; set; }

        [Column("user_id")]
        public long UserId { get; set; }

        public required string Token { get; set; }

        [Column("expires_at")]
        public DateTime ExpiresAt { get; set; }

        [Column("is_revoked")]
        public bool IsRevoked { get; set; }

        public User User { get; set; }

    }
}
