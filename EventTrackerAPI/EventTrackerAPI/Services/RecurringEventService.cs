using EventTrackerAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace EventTrackerAPI.Services
{
    public class RecurringEventService
    {
        private readonly EventTrackerDbContext _context;

        public RecurringEventService(EventTrackerDbContext context)
        {
            _context = context;
        }

        public async Task<List<Event>> GenerateRecurringEventInstancesAsync(Event parentEvent, DateTime startDate, DateTime endDate)
        {
            if (!parentEvent.IsRecurring || string.IsNullOrEmpty(parentEvent.RecurrenceType))
            {
                return new List<Event>();
            }

            var instances = new List<Event>();
            var currentDate = parentEvent.StartDateTime;

            // Don't generate instances before the start date
            if (currentDate < startDate)
            {
                currentDate = GetNextOccurrence(parentEvent, startDate);
            }

            while (currentDate <= endDate)
            {
                // Stop if we've reached the recurrence end date
                if (parentEvent.RecurrenceEndDate.HasValue && currentDate > parentEvent.RecurrenceEndDate.Value)
                {
                    break;
                }

                // Don't create an instance for the original event date
                if (currentDate != parentEvent.StartDateTime)
                {
                    var instance = CreateEventInstance(parentEvent, currentDate);
                    instances.Add(instance);
                }

                currentDate = GetNextOccurrence(parentEvent, currentDate);
            }

            return instances;
        }

        private Event CreateEventInstance(Event parentEvent, DateTime instanceDate)
        {
            var duration = parentEvent.EndDateTime?.Subtract(parentEvent.StartDateTime);
            
            return new Event
            {
                Id = Guid.NewGuid().ToString(),
                Title = parentEvent.Title,
                Description = parentEvent.Description,
                StartDateTime = instanceDate,
                EndDateTime = duration.HasValue ? instanceDate.Add(duration.Value) : null,
                Address = parentEvent.Address,
                CategoryId = parentEvent.CategoryId,
                EventType = parentEvent.EventType,
                MaxCapacity = parentEvent.MaxCapacity,
                IsCancelled = false,
                IsCompleted = false,
                IsVisible = parentEvent.IsVisible,
                CreatedBy = parentEvent.CreatedBy,
                CreatedAt = DateTime.UtcNow,
                IsRecurring = false, // Instances are not recurring themselves
                ParentEventId = parentEvent.Id
            };
        }

        private DateTime GetNextOccurrence(Event parentEvent, DateTime currentDate)
        {
            return parentEvent.RecurrenceType?.ToLower() switch
            {
                "daily" => currentDate.AddDays(parentEvent.RecurrenceInterval),
                "weekly" => currentDate.AddDays(7 * parentEvent.RecurrenceInterval),
                "monthly" => currentDate.AddMonths(parentEvent.RecurrenceInterval),
                "yearly" => currentDate.AddYears(parentEvent.RecurrenceInterval),
                _ => currentDate.AddDays(1) // Default fallback
            };
        }

        public async Task<List<Event>> GetEventsWithInstancesAsync(string userId, DateTime startDate, DateTime endDate)
        {
            var allEvents = new List<Event>();

            // Get regular events (non-recurring and parent recurring events)
            var regularEvents = await _context.Events
                .Where(e => e.CreatedBy == userId && 
                           e.StartDateTime >= startDate && 
                           e.StartDateTime <= endDate)
                .Include(e => e.Category)
                .ToListAsync();

            allEvents.AddRange(regularEvents);

            // Get recurring events and generate their instances
            var recurringEvents = await _context.Events
                .Where(e => e.CreatedBy == userId && 
                           e.IsRecurring && 
                           string.IsNullOrEmpty(e.ParentEventId)) // Only parent events
                .Include(e => e.Category)
                .ToListAsync();

            foreach (var recurringEvent in recurringEvents)
            {
                var instances = await GenerateRecurringEventInstancesAsync(recurringEvent, startDate, endDate);
                allEvents.AddRange(instances);
            }

            return allEvents.OrderBy(e => e.StartDateTime).ToList();
        }

        public async Task<bool> DeleteRecurringEventAsync(string eventId, bool deleteAllInstances = false)
        {
            var eventToDelete = await _context.Events.FindAsync(eventId);
            if (eventToDelete == null) return false;

            if (deleteAllInstances && eventToDelete.IsRecurring)
            {
                // Delete all instances of this recurring event
                var instances = await _context.Events
                    .Where(e => e.ParentEventId == eventId)
                    .ToListAsync();

                _context.Events.RemoveRange(instances);
            }

            _context.Events.Remove(eventToDelete);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<Event?> UpdateRecurringEventAsync(Event updatedEvent, bool updateAllInstances = false)
        {
            var existingEvent = await _context.Events.FindAsync(updatedEvent.Id);
            if (existingEvent == null) return null;

            // Update the parent event
            existingEvent.Title = updatedEvent.Title;
            existingEvent.Description = updatedEvent.Description;
            existingEvent.Address = updatedEvent.Address;
            existingEvent.CategoryId = updatedEvent.CategoryId;
            existingEvent.EventType = updatedEvent.EventType;
            existingEvent.MaxCapacity = updatedEvent.MaxCapacity;
            existingEvent.IsVisible = updatedEvent.IsVisible;
            existingEvent.UpdatedAt = DateTime.UtcNow;

            // Update recurrence settings
            existingEvent.IsRecurring = updatedEvent.IsRecurring;
            existingEvent.RecurrenceType = updatedEvent.RecurrenceType;
            existingEvent.RecurrenceInterval = updatedEvent.RecurrenceInterval;
            existingEvent.RecurrenceEndDate = updatedEvent.RecurrenceEndDate;

            if (updateAllInstances && existingEvent.IsRecurring)
            {
                // Update all instances (excluding time-specific fields)
                var instances = await _context.Events
                    .Where(e => e.ParentEventId == existingEvent.Id)
                    .ToListAsync();

                foreach (var instance in instances)
                {
                    instance.Title = updatedEvent.Title;
                    instance.Description = updatedEvent.Description;
                    instance.Address = updatedEvent.Address;
                    instance.CategoryId = updatedEvent.CategoryId;
                    instance.EventType = updatedEvent.EventType;
                    instance.MaxCapacity = updatedEvent.MaxCapacity;
                    instance.IsVisible = updatedEvent.IsVisible;
                    instance.UpdatedAt = DateTime.UtcNow;
                }
            }

            await _context.SaveChangesAsync();
            return existingEvent;
        }
    }
}
