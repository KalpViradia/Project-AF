using Microsoft.AspNetCore.Mvc;
using EventTrackerAPI.Models;
using EventTrackerAPI.Models.DTOs;
using EventTrackerAPI.Services;
using Microsoft.EntityFrameworkCore;

namespace EventTrackerAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EventsController : ControllerBase
    {
        private readonly EventTrackerDbContext _context;
        private readonly RecurringEventService _recurringEventService;
        
        public EventsController(EventTrackerDbContext context, RecurringEventService recurringEventService)
        {
            _context = context;
            _recurringEventService = recurringEventService;
        }

        private EventDTO MapToEventDTO(Event e)
        {
            return new EventDTO
            {
                Id = e.Id,
                Title = e.Title,
                Description = e.Description,
                StartDateTime = e.StartDateTime,
                EndDateTime = e.EndDateTime,
                Address = e.Address,
                CategoryId = e.CategoryId,
                Category = e.Category != null ? new CategoryDTO
                {
                    CategoryId = e.Category.CategoryId,
                    Name = e.Category.Name,
                    Description = e.Category.Description,
                    Color = e.Category.Color,
                    Icon = e.Category.Icon,
                    IsActive = e.Category.IsActive
                } : null,
                EventType = e.EventType,
                MaxCapacity = e.MaxCapacity,
                IsCancelled = e.IsCancelled,
                IsCompleted = e.IsCompleted,
                IsVisible = e.IsVisible,
                CreatedBy = e.CreatedBy,
                CreatedByUser = e.CreatedByNavigation != null ? new UserDTO
                {
                    UserId = e.CreatedByNavigation.UserId,
                    Name = e.CreatedByNavigation.Name,
                    Email = e.CreatedByNavigation.Email,
                    Phone = e.CreatedByNavigation.Phone,
                    Address = e.CreatedByNavigation.Address,
                    DateOfBirth = e.CreatedByNavigation.DateOfBirth,
                    IsActive = e.CreatedByNavigation.IsActive
                } : null,
                CreatedAt = e.CreatedAt,
                UpdatedAt = e.UpdatedAt,
                IsRecurring = e.IsRecurring,
                RecurrenceType = e.RecurrenceType,
                RecurrenceInterval = e.RecurrenceInterval,
                RecurrenceEndDate = e.RecurrenceEndDate,
                ParentEventId = e.ParentEventId
            };
        }

        [HttpGet]
        public async Task<IActionResult> GetEvents([FromQuery] string? userId, [FromQuery] string? search)
        {
            var query = _context.Events
                .Include(e => e.Category)
                .Include(e => e.CreatedByNavigation)
                .AsQueryable();

            if (!string.IsNullOrEmpty(userId))
                query = query.Where(e => e.CreatedBy == userId);
            if (!string.IsNullOrEmpty(search))
                query = query.Where(e => (e.Title != null && e.Title.Contains(search)) || (e.Description != null && e.Description.Contains(search)));

            var events = await query.ToListAsync();
            var eventDTOs = events.Select(e => MapToEventDTO(e)).ToList();

            return Ok(eventDTOs);
        }

        [HttpGet("invisible")]
        public async Task<IActionResult> GetInvisibleEvents([FromQuery] string? userId)
        {
            var query = _context.Events
                .Include(e => e.Category)
                .Include(e => e.CreatedByNavigation)
                .Where(e => e.IsVisible == false);

            if (!string.IsNullOrEmpty(userId))
                query = query.Where(e => e.CreatedBy == userId);

            var events = await query.ToListAsync();
            var eventDTOs = events.Select(e => MapToEventDTO(e)).ToList();

            return Ok(eventDTOs);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetEventById(string id)
        {
            var ev = await _context.Events
                .Include(e => e.Category)
                .Include(e => e.CreatedByNavigation)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (ev == null) return NotFound();

            var eventDTO = MapToEventDTO(ev);
            
            return Ok(eventDTO);
        }

        [HttpPost]
        public async Task<IActionResult> CreateEvent([FromBody] EventCreateRequest request)
        {
            // Validate category if provided
            if (request.CategoryId.HasValue)
            {
                var categoryExists = await _context.Categories.AnyAsync(c => c.CategoryId == request.CategoryId.Value);
                if (!categoryExists)
                {
                    return BadRequest(new { message = $"Category with ID {request.CategoryId.Value} does not exist" });
                }
            }

            // Validate user exists
            var userExists = await _context.Users.AnyAsync(u => u.UserId == request.CreatedBy);
            if (!userExists)
            {
                return BadRequest(new { message = $"User with ID {request.CreatedBy} does not exist" });
            }

            var ev = new Event 
            { 
                Id = Guid.NewGuid().ToString(), 
                Title = request.Title, 
                Description = request.Description, 
                StartDateTime = request.StartDateTime, 
                EndDateTime = request.EndDateTime, 
                Address = request.Address, 
                CategoryId = request.CategoryId, 
                EventType = request.EventType, 
                MaxCapacity = request.MaxCapacity, 
                CreatedBy = request.CreatedBy, 
                CreatedAt = DateTime.UtcNow, 
                IsVisible = true, 
                IsCancelled = false, 
                IsCompleted = false,
                IsRecurring = request.IsRecurring,
                RecurrenceType = request.RecurrenceType,
                RecurrenceInterval = request.RecurrenceInterval,
                RecurrenceEndDate = request.RecurrenceEndDate
            };

            _context.Events.Add(ev);
            await _context.SaveChangesAsync();

            // Load the event with its navigation properties
            var createdEvent = await _context.Events
                .Include(e => e.CreatedByNavigation)
                .Include(e => e.Category)
                .FirstOrDefaultAsync(e => e.Id == ev.Id);

            if (createdEvent == null)
            {
                return StatusCode(500, new { message = "Error occurred while creating the event." });
            }

            var eventDTO = new EventDTO
            {
                Id = createdEvent.Id,
                Title = createdEvent.Title,
                Description = createdEvent.Description,
                StartDateTime = createdEvent.StartDateTime,
                EndDateTime = createdEvent.EndDateTime,

                Address = createdEvent.Address,
                CategoryId = createdEvent.CategoryId,
                Category = createdEvent.Category != null ? new CategoryDTO
                {
                    CategoryId = createdEvent.Category.CategoryId,
                    Name = createdEvent.Category.Name,
                    Description = createdEvent.Category.Description,
                    Color = createdEvent.Category.Color,
                    Icon = createdEvent.Category.Icon,
                    IsActive = createdEvent.Category.IsActive
                } : null,
                EventType = createdEvent.EventType,
                MaxCapacity = createdEvent.MaxCapacity,
                IsCancelled = createdEvent.IsCancelled,
                IsCompleted = createdEvent.IsCompleted,
                IsVisible = createdEvent.IsVisible,
                CreatedBy = createdEvent.CreatedBy,
                CreatedByUser = createdEvent.CreatedByNavigation != null ? new UserDTO
                {
                    UserId = createdEvent.CreatedByNavigation.UserId,
                    Name = createdEvent.CreatedByNavigation.Name,
                    Email = createdEvent.CreatedByNavigation.Email,
                    Phone = createdEvent.CreatedByNavigation.Phone,
                    Address = createdEvent.CreatedByNavigation.Address,
                    DateOfBirth = createdEvent.CreatedByNavigation.DateOfBirth,
                    IsActive = createdEvent.CreatedByNavigation.IsActive
                } : null,
                CreatedAt = createdEvent.CreatedAt,
                UpdatedAt = createdEvent.UpdatedAt
            };

            return Ok(eventDTO);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateEvent(string id, [FromBody] EventUpdateRequest request)
        {
            var ev = await _context.Events.FirstOrDefaultAsync(e => e.Id == id);
            if (ev == null) return NotFound();

            // Validate category if provided
            if (request.CategoryId.HasValue)
            {
                var categoryExists = await _context.Categories.AnyAsync(c => c.CategoryId == request.CategoryId.Value);
                if (!categoryExists)
                {
                    return BadRequest(new { message = $"Category with ID {request.CategoryId.Value} does not exist" });
                }
            }

            // Update fields
            ev.Title = request.Title;
            ev.Description = request.Description;
            ev.StartDateTime = request.StartDateTime;
            ev.EndDateTime = request.EndDateTime;
            ev.Address = request.Address;
            ev.CategoryId = request.CategoryId;
            ev.EventType = request.EventType;
            ev.MaxCapacity = request.MaxCapacity;
            ev.IsRecurring = request.IsRecurring;
            ev.RecurrenceType = request.RecurrenceType;
            ev.RecurrenceInterval = request.RecurrenceInterval;
            ev.RecurrenceEndDate = request.RecurrenceEndDate;
            ev.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            // Load the updated event with its navigation properties
            var updatedEvent = await _context.Events
                .Include(e => e.CreatedByNavigation)
                .Include(e => e.Category)
                .FirstOrDefaultAsync(e => e.Id == ev.Id);

            if (updatedEvent == null)
            {
                return StatusCode(500, new { message = "Error occurred while updating the event." });
            }

            var eventDTO = MapToEventDTO(updatedEvent);

            return Ok(eventDTO);
        }

        [HttpPatch("{id}/status")]
        public async Task<IActionResult> UpdateEventStatus(string id, [FromBody] EventStatusRequest req)
        {
            var ev = await _context.Events.FirstOrDefaultAsync(e => e.Id == id);
            if (ev == null) return NotFound();

            if (req.IsCancelled.HasValue) ev.IsCancelled = req.IsCancelled.Value;
            if (req.IsCompleted.HasValue) ev.IsCompleted = req.IsCompleted.Value;
            ev.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            // Load the updated event with its navigation properties
            var updatedEvent = await _context.Events
                .Include(e => e.CreatedByNavigation)
                .Include(e => e.Category)
                .FirstOrDefaultAsync(e => e.Id == ev.Id);

            if (updatedEvent == null)
            {
                return StatusCode(500, new { message = "Error occurred while updating the event status." });
            }

            var eventDTO = new EventDTO
            {
                Id = updatedEvent.Id,
                Title = updatedEvent.Title,
                Description = updatedEvent.Description,
                StartDateTime = updatedEvent.StartDateTime,
                EndDateTime = updatedEvent.EndDateTime,
                Address = updatedEvent.Address,
                CategoryId = updatedEvent.CategoryId,
                Category = updatedEvent.Category != null ? new CategoryDTO
                {
                    CategoryId = updatedEvent.Category.CategoryId,
                    Name = updatedEvent.Category.Name,
                    Description = updatedEvent.Category.Description,
                    Color = updatedEvent.Category.Color,
                    Icon = updatedEvent.Category.Icon,
                    IsActive = updatedEvent.Category.IsActive
                } : null,
                EventType = updatedEvent.EventType,
                MaxCapacity = updatedEvent.MaxCapacity,
                IsCancelled = updatedEvent.IsCancelled,
                IsCompleted = updatedEvent.IsCompleted,
                IsVisible = updatedEvent.IsVisible,
                CreatedBy = updatedEvent.CreatedBy,
                CreatedByUser = updatedEvent.CreatedByNavigation != null ? new UserDTO
                {
                    UserId = updatedEvent.CreatedByNavigation.UserId,
                    Name = updatedEvent.CreatedByNavigation.Name,
                    Email = updatedEvent.CreatedByNavigation.Email,
                    Phone = updatedEvent.CreatedByNavigation.Phone,
                    Address = updatedEvent.CreatedByNavigation.Address,
                    DateOfBirth = updatedEvent.CreatedByNavigation.DateOfBirth,
                    IsActive = updatedEvent.CreatedByNavigation.IsActive
                } : null,
                CreatedAt = updatedEvent.CreatedAt,
                UpdatedAt = updatedEvent.UpdatedAt
            };

            return Ok(eventDTO);
        }

        [HttpPatch("{id}/visibility")]
        public async Task<IActionResult> UpdateEventVisibility(string id, [FromBody] EventVisibilityRequest req)
        {
            var ev = await _context.Events.FirstOrDefaultAsync(e => e.Id == id);
            if (ev == null) return NotFound();

            ev.IsVisible = req.IsVisible;
            ev.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            // Load the updated event with its navigation properties
            var updatedEvent = await _context.Events
                .Include(e => e.CreatedByNavigation)
                .Include(e => e.Category)
                .FirstOrDefaultAsync(e => e.Id == ev.Id);

            if (updatedEvent == null)
            {
                return StatusCode(500, new { message = "Error occurred while updating the event visibility." });
            }

            var eventDTO = new EventDTO
            {
                Id = updatedEvent.Id,
                Title = updatedEvent.Title,
                Description = updatedEvent.Description,
                StartDateTime = updatedEvent.StartDateTime,
                EndDateTime = updatedEvent.EndDateTime,
                Address = updatedEvent.Address,
                CategoryId = updatedEvent.CategoryId,
                Category = updatedEvent.Category != null ? new CategoryDTO
                {
                    CategoryId = updatedEvent.Category.CategoryId,
                    Name = updatedEvent.Category.Name,
                    Description = updatedEvent.Category.Description,
                    Color = updatedEvent.Category.Color,
                    Icon = updatedEvent.Category.Icon,
                    IsActive = updatedEvent.Category.IsActive
                } : null,
                EventType = updatedEvent.EventType,
                MaxCapacity = updatedEvent.MaxCapacity,
                IsCancelled = updatedEvent.IsCancelled,
                IsCompleted = updatedEvent.IsCompleted,
                IsVisible = updatedEvent.IsVisible,
                CreatedBy = updatedEvent.CreatedBy,
                CreatedByUser = updatedEvent.CreatedByNavigation != null ? new UserDTO
                {
                    UserId = updatedEvent.CreatedByNavigation.UserId,
                    Name = updatedEvent.CreatedByNavigation.Name,
                    Email = updatedEvent.CreatedByNavigation.Email,
                    Phone = updatedEvent.CreatedByNavigation.Phone,
                    Address = updatedEvent.CreatedByNavigation.Address,
                    DateOfBirth = updatedEvent.CreatedByNavigation.DateOfBirth,
                    IsActive = updatedEvent.CreatedByNavigation.IsActive
                } : null,
                CreatedAt = updatedEvent.CreatedAt,
                UpdatedAt = updatedEvent.UpdatedAt
            };

            return Ok(eventDTO);
        }

        [HttpGet("{id}/capacity")]
        public async Task<IActionResult> GetEventCapacity(string id)
        {
            try
            {
                var eventEntity = await _context.Events.FindAsync(id);
                if (eventEntity == null)
                {
                    return NotFound(new { message = "Event not found" });
                }

                // Calculate total accepted participants
                int totalAcceptedParticipants;
                try
                {
                    // First check if there are any accepted invites
                    var acceptedInvitesCount = await _context.EventInvites
                        .Where(ei => ei.EventId == id && ei.Status == InviteStatus.Accepted)
                        .CountAsync();
                    
                    if (acceptedInvitesCount == 0)
                    {
                        totalAcceptedParticipants = 0;
                    }
                    else
                    {
                        totalAcceptedParticipants = await _context.EventInvites
                            .Where(ei => ei.EventId == id && ei.Status == InviteStatus.Accepted)
                            .SumAsync(ei => ei.ParticipantCount);
                    }
                }
                catch (Exception ex)
                {
                    // Fallback: count accepted invites as 1 participant each
                    totalAcceptedParticipants = await _context.EventInvites
                        .Where(ei => ei.EventId == id && ei.Status == InviteStatus.Accepted)
                        .CountAsync();
                }

                var maxCapacity = eventEntity.MaxCapacity ?? 0;
                var availableSpaces = maxCapacity - totalAcceptedParticipants;

                var response = new
                {
                    EventId = id,
                    MaxCapacity = maxCapacity,
                    AcceptedParticipants = totalAcceptedParticipants,
                    AvailableSpaces = Math.Max(0, availableSpaces)
                };
                
                return Ok(response);
            }
            catch (Exception ex)
            {
                // Return default values if there's an error (e.g., column doesn't exist yet)
                var eventEntity = await _context.Events.FindAsync(id);
                if (eventEntity == null)
                {
                    return NotFound(new { message = "Event not found" });
                }

                return Ok(new
                {
                    EventId = id,
                    MaxCapacity = eventEntity.MaxCapacity ?? 0,
                    AcceptedParticipants = 0,
                    AvailableSpaces = eventEntity.MaxCapacity ?? 0
                });
            }
        }
    }

    public class EventStatusRequest
    {
        public bool? IsCancelled { get; set; }
        public bool? IsCompleted { get; set; }
    }
    public class EventVisibilityRequest
    {
        public bool IsVisible { get; set; }
    }

    public class EventCreateRequest
    {
        public required string Title { get; set; }
        public string? Description { get; set; }
        public DateTime StartDateTime { get; set; }
        public DateTime? EndDateTime { get; set; }
        public string? Address { get; set; }
        public int? CategoryId { get; set; }
        public string? EventType { get; set; }
        public int? MaxCapacity { get; set; }
        public required string CreatedBy { get; set; }
        
        // Recurring event properties
        public bool IsRecurring { get; set; } = false;
        public string? RecurrenceType { get; set; }
        public int RecurrenceInterval { get; set; } = 1;
        public DateTime? RecurrenceEndDate { get; set; }
    }

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
        
        // Recurring event properties
        public bool IsRecurring { get; set; } = false;
        public string? RecurrenceType { get; set; }
        public int RecurrenceInterval { get; set; } = 1;
        public DateTime? RecurrenceEndDate { get; set; }
    }
}
