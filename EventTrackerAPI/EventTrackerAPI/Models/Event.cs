using System;
using System.Collections.Generic;

namespace EventTrackerAPI.Models;

public partial class Event
{
    public string Id { get; set; } = null!;

    public string Title { get; set; } = null!;

    public virtual ICollection<EventInvite> EventInvites { get; set; } = new List<EventInvite>();

    public string? Description { get; set; }

    public DateTime StartDateTime { get; set; }

    public DateTime? EndDateTime { get; set; }


    public string? Address { get; set; }

    public int? CategoryId { get; set; }

    public string? EventType { get; set; }


    public int? MaxCapacity { get; set; }

    public bool IsCancelled { get; set; }

    public bool IsCompleted { get; set; }

    public bool IsVisible { get; set; }

    public string CreatedBy { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime? UpdatedAt { get; set; }

    // Recurring event properties
    public bool IsRecurring { get; set; } = false;

    public string? RecurrenceType { get; set; } // "None", "Daily", "Weekly", "Monthly", "Yearly"

    public int RecurrenceInterval { get; set; } = 1; // Every X days/weeks/months/years

    public DateTime? RecurrenceEndDate { get; set; } // When to stop generating occurrences

    public string? ParentEventId { get; set; } // For event instances, reference to parent

    public virtual Category? Category { get; set; }

    public virtual User CreatedByNavigation { get; set; } = null!;

    public virtual ICollection<EventUser> EventUsers { get; set; } = new List<EventUser>();
}
