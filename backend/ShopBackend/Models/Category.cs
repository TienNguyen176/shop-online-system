using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

[Table("categories")]
public class Category
{
    [Key]
    public long Id { get; set; }

    [Required]
    public string Name { get; set; }

    [Required]
    public string Slug { get; set; }

    [Column("parent_id")]
    public long? ParentId { get; set; }

    public int Level { get; set; }

    public string? Image { get; set; }
}