using System;
using System.ComponentModel.DataAnnotations;

namespace EventTrackerAPI.Models;

public partial class EventComment
{
    [Key]
    public string Id { get; set; } = Guid.NewGuid().ToString();

    [Required]
    public string EventId { get; set; } = null!;

    [Required]
    public string UserId { get; set; } = null!;

    [Required]
    [MaxLength(1000)]
    public string Content { get; set; } = null!;

    [MaxLength(20)]
    public string CommentType { get; set; } = "comment"; // "comment" or "announcement"

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? UpdatedAt { get; set; }

    public bool IsDeleted { get; set; } = false;

    // Navigation properties
    public virtual Event Event { get; set; } = null!;
    public virtual User User { get; set; } = null!;
}
