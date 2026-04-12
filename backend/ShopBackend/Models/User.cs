using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ShopBackend.Models
{
    public class User
    {
        public int Id { get; set; }
        
        [Column("provider")]
        public required string Provider { get; set; } // google | facebook

        [Column("provider_user_id")]
        public required string ProviderUserId { get; set; }

        [Column("email")]
        public string? Email { get; set; }

        [Column("full_name")]
        public required string FullName { get; set; }

        [Column("avatar")]
        public required string Avatar { get; set; }

        [Column("role")]
        public required string Role { get; set; } // user | admin

        [Column("created_at")]
        public DateTime CreatedAt { get; set; }
    }
}