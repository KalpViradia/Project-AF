using System;

namespace EventTrackerAPI.Models
{
    public class SavedInvitee
    {
        public string OwnerUserId { get; set; } = null!;
        public string SavedUserId { get; set; } = null!;
        public DateTime CreatedAt { get; set; }

        public virtual User OwnerUser { get; set; } = null!;
        public virtual User SavedUser { get; set; } = null!;
    }
}
