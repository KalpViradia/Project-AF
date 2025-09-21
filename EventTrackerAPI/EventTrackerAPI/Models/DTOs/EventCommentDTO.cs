using System;

namespace EventTrackerAPI.Models.DTOs;

public class EventCommentDTO
{
    public string Id { get; set; } = null!;
    public string EventId { get; set; } = null!;
    public string UserId { get; set; } = null!;
    public string Content { get; set; } = null!;
    public string CommentType { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public UserDTO User { get; set; } = null!;
}

public class EventCommentCreateRequest
{
    public string EventId { get; set; } = null!;
    public string Content { get; set; } = null!;
    public string CommentType { get; set; } = "comment"; // "comment" or "announcement"
    // Optional: allow client to provide userId when JWT is unavailable (e.g., dev/testing)
    public string? UserId { get; set; }
}

public class EventCommentUpdateRequest
{
    public string Content { get; set; } = null!;
}
