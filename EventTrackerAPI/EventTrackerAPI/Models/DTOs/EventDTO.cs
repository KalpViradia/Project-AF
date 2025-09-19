using System;

namespace EventTrackerAPI.Models.DTOs
{
    public class EventDTO
    {
        public string Id { get; set; } = null!;
        public string Title { get; set; } = null!;
        public string? Description { get; set; }
        public DateTime StartDateTime { get; set; }
        public DateTime? EndDateTime { get; set; }
        public string? Address { get; set; }
        public int? CategoryId { get; set; }
        public CategoryDTO? Category { get; set; }
        public string? EventType { get; set; }
        public int? MaxCapacity { get; set; }
        public bool IsCancelled { get; set; }
        public bool IsCompleted { get; set; }
        public bool IsVisible { get; set; }
        public string CreatedBy { get; set; } = null!;
        public UserDTO? CreatedByUser { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
        
        // Recurring event properties
        public bool IsRecurring { get; set; }
        public string? RecurrenceType { get; set; }
        public int RecurrenceInterval { get; set; }
        public DateTime? RecurrenceEndDate { get; set; }
        public string? ParentEventId { get; set; }
    }

    public class CategoryDTO
    {
        public int CategoryId { get; set; }
        public string Name { get; set; } = null!;
        public string? Description { get; set; }
        public string? Color { get; set; }
        public string? Icon { get; set; }
        public int IsActive { get; set; }
    }

    public class UserDTO
    {
        public string UserId { get; set; } = null!;
        public string Name { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string? Phone { get; set; }
        public string? Address { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public int IsActive { get; set; }
    }
}
