using System;
using System.Collections.Generic;

namespace EventTrackerAPI.Models;

public partial class User
{
    public string UserId { get; set; } = null!;

    public string Name { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string Password { get; set; } = null!;

    public string? Phone { get; set; }

    public string? CountryCode { get; set; }

    public string? Address { get; set; }

    public DateTime? DateOfBirth { get; set; }

    public string? Gender { get; set; }

    public string? Bio { get; set; }

    public int IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? LastLogin { get; set; }

    public bool IsLoggedIn { get; set; } = false;

    public virtual ICollection<Event> Events { get; set; } = new List<Event>();

    public virtual ICollection<SavedInvitee> SavedInvitees { get; set; } = new List<SavedInvitee>();
}
