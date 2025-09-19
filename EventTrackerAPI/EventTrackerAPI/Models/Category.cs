using System;
using System.Collections.Generic;

namespace EventTrackerAPI.Models;

public partial class Category
{
    public int CategoryId { get; set; }

    public string Name { get; set; } = null!;

    public string? Description { get; set; }

    public string? Color { get; set; }

    public string? Icon { get; set; }

    public int IsActive { get; set; } = 1;

    public virtual ICollection<Event> Events { get; set; } = new List<Event>();
}
