using System;

namespace EventTrackerAPI.Models
{
    public class EventInvite
    {
        public string Id { get; set; } = null!;
        public string EventId { get; set; } = null!;
        public string InvitedUserId { get; set; } = null!;
        public InviteStatus Status { get; set; } = InviteStatus.Pending;
        public int ParticipantCount { get; set; } = 1;
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }

        public virtual Event Event { get; set; } = null!;
        public virtual User InvitedUser { get; set; } = null!;
    }
}
