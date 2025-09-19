using System;
using System.Collections.Generic;

namespace EventTrackerAPI.Models;

public partial class EventUser
{
    public string EventId { get; set; } = null!;

    public string UserId { get; set; } = null!;

    public string Role { get; set; } = null!;

    public string Status { get; set; } = null!;

    public int Adults { get; set; }

    public int Children { get; set; }

    public string? Note { get; set; }

    public DateTime InvitedAt { get; set; }

    public DateTime? RespondedAt { get; set; }

    public virtual Event Event { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
