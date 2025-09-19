using System;

namespace EventTrackerAPI.Models.DTOs
{
    public class EventInviteDTO
    {
        public string Id { get; set; } = null!;
        public string EventId { get; set; } = null!;
        public EventDTO? Event { get; set; }
        public string InvitedUserId { get; set; } = null!;
        public UserDTO? InvitedUser { get; set; }
        public string Status { get; set; } = null!;
        public int ParticipantCount { get; set; } = 1;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class EventInviteCreateRequest
    {
        public required string EventId { get; set; }
        public required string InvitedUserId { get; set; }
        public int ParticipantCount { get; set; } = 1;
    }

    public class EventInviteStatusRequest
    {
        public required string Status { get; set; }
        public int? ParticipantCount { get; set; }
    }
}
