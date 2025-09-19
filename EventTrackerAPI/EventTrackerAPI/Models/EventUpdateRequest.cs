namespace EventTrackerAPI.Models
{
    public class EventUpdateRequest
    {
        public required string Title { get; set; }
        public string? Description { get; set; }
        public DateTime StartDateTime { get; set; }
        public DateTime? EndDateTime { get; set; }
        public string? Address { get; set; }
        public int? CategoryId { get; set; }
        public string? EventType { get; set; }
        public int? MaxCapacity { get; set; }
    }
}
