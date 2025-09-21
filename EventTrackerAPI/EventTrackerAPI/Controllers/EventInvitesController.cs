using Microsoft.AspNetCore.Mvc;
using EventTrackerAPI.Models;
using EventTrackerAPI.Models.DTOs;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace EventTrackerAPI.Controllers
{
    [ApiController]
    [Route("api/event-invites")]
    public class EventInvitesController : ControllerBase
    {
        private readonly EventTrackerDbContext _context;
        public EventInvitesController(EventTrackerDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetInvites([FromQuery] string? userId, [FromQuery] string? eventId)
        {
            var query = _context.EventInvites
                .Include(ei => ei.Event)
                    .ThenInclude(e => e.Category)
                .Include(ei => ei.Event)
                    .ThenInclude(e => e.CreatedByNavigation)
                .Include(ei => ei.InvitedUser)
                .AsQueryable();

            if (!string.IsNullOrEmpty(userId))
            {
                query = query.Where(ei => ei.InvitedUserId == userId);
            }

            if (!string.IsNullOrEmpty(eventId))
            {
                query = query.Where(ei => ei.EventId == eventId);
            }

            var invites = await query.ToListAsync();

            var inviteDTOs = invites.Select(ei => MapToEventInviteDTO(ei)).ToList();

            return Ok(inviteDTOs);
        }

        [HttpPost]
        public async Task<IActionResult> CreateInvite([FromBody] EventInviteCreateRequest request)
        {
            // Validate event exists
            var eventExists = await _context.Events.AnyAsync(e => e.Id == request.EventId);
            if (!eventExists)
            {
                return BadRequest(new { message = $"Event with ID {request.EventId} does not exist" });
            }

            // Validate user exists
            var userExists = await _context.Users.AnyAsync(u => u.UserId == request.InvitedUserId);
            if (!userExists)
            {
                return BadRequest(new { message = $"User with ID {request.InvitedUserId} does not exist" });
            }

            // Check if invite already exists
            var existingInvite = await _context.EventInvites
                .FirstOrDefaultAsync(ei => ei.EventId == request.EventId && ei.InvitedUserId == request.InvitedUserId);
            
            if (existingInvite != null)
            {
                return BadRequest(new { message = "Invite already exists for this user and event" });
            }

            var invite = new EventInvite
            {
                Id = Guid.NewGuid().ToString(),
                EventId = request.EventId,
                InvitedUserId = request.InvitedUserId,
                Status = InviteStatus.Pending,
                ParticipantCount = request.ParticipantCount,
                CreatedAt = DateTime.UtcNow
            };

            _context.EventInvites.Add(invite);
            await _context.SaveChangesAsync();

            // Load the created invite with its navigation properties
            var createdInvite = await _context.EventInvites
                .Include(ei => ei.Event)
                    .ThenInclude(e => e.Category)
                .Include(ei => ei.Event)
                    .ThenInclude(e => e.CreatedByNavigation)
                .Include(ei => ei.InvitedUser)
                .FirstOrDefaultAsync(ei => ei.Id == invite.Id);

            if (createdInvite == null)
            {
                return StatusCode(500, new { message = "Error occurred while creating the invite" });
            }

            var inviteDTO = MapToEventInviteDTO(createdInvite);
            return Ok(inviteDTO);
        }

        [HttpPut("{inviteId}/status")]
        public async Task<IActionResult> UpdateInviteStatus(string inviteId, [FromBody] EventInviteStatusRequest request)
        {
            var invite = await _context.EventInvites
                .Include(ei => ei.Event)
                    .ThenInclude(e => e.Category)
                .Include(ei => ei.Event)
                    .ThenInclude(e => e.CreatedByNavigation)
                .Include(ei => ei.InvitedUser)
                .FirstOrDefaultAsync(ei => ei.Id == inviteId);

            if (invite == null)
            {
                return NotFound(new { message = $"Event invite with ID {inviteId} does not exist" });
            }

            // Handle case-insensitive status parsing
            var statusLower = request.Status.ToLower();
            InviteStatus status;
            switch (statusLower)
            {
                case "pending":
                    status = InviteStatus.Pending;
                    break;
                case "accepted":
                    status = InviteStatus.Accepted;
                    break;
                case "declined":
                    status = InviteStatus.Declined;
                    break;
                case "cancelled":
                    status = InviteStatus.Cancelled;
                    break;
                default:
                    return BadRequest(new { message = "Invalid status. Allowed values are: pending, accepted, declined, cancelled" });
            }

            // If accepting, enforce capacity unless unlimited (MaxCapacity null)
            if (status == InviteStatus.Accepted)
            {
                await using var tx = await _context.Database.BeginTransactionAsync(System.Data.IsolationLevel.Serializable);
                try
                {
                    // Reload event to get capacity inside transaction
                    var ev = invite.Event ?? await _context.Events.FirstOrDefaultAsync(e => e.Id == invite.EventId);
                    if (ev == null)
                    {
                        return BadRequest(new { message = "Event not found for this invite" });
                    }

                    var participantCount = request.ParticipantCount.HasValue ? request.ParticipantCount.Value : invite.ParticipantCount;
                    if (participantCount <= 0) participantCount = 1;

                    if (ev.MaxCapacity.HasValue && ev.MaxCapacity.Value > 0)
                    {
                        // Calculate currently accepted participants excluding this invite
                        var currentAccepted = await _context.EventInvites
                            .Where(ei => ei.EventId == invite.EventId && ei.Status == InviteStatus.Accepted && ei.Id != invite.Id)
                            .SumAsync(ei => (int?)ei.ParticipantCount) ?? 0;

                        var available = ev.MaxCapacity.Value - currentAccepted;
                        if (available < participantCount)
                        {
                            return BadRequest(new { message = $"Capacity exceeded. Only {Math.Max(0, available)} spaces available." });
                        }
                    }

                    // Safe to accept within transaction
                    invite.Status = status;
                    if (request.ParticipantCount.HasValue)
                    {
                        invite.ParticipantCount = request.ParticipantCount.Value;
                        Console.WriteLine($"Updated participant count to: {invite.ParticipantCount}");
                    }
                    invite.UpdatedAt = DateTime.UtcNow;

                    await _context.SaveChangesAsync();
                    await tx.CommitAsync();
                }
                catch
                {
                    await tx.RollbackAsync();
                    throw;
                }
            }
            else
            {
                // Non-acceptance paths don't need capacity enforcement
                invite.Status = status;
                if (request.ParticipantCount.HasValue)
                {
                    invite.ParticipantCount = request.ParticipantCount.Value;
                    Console.WriteLine($"Updated participant count to: {invite.ParticipantCount}");
                }
                invite.UpdatedAt = DateTime.UtcNow;
                await _context.SaveChangesAsync();
            }

            await _context.Entry(invite)
                .Reference(x => x.Event).LoadAsync();
            
            if (invite.Event != null)
            {
                await _context.Entry(invite.Event)
                    .Reference(x => x.Category).LoadAsync();
                await _context.Entry(invite.Event)
                    .Reference(x => x.CreatedByNavigation).LoadAsync();
            }
            
            await _context.Entry(invite)
                .Reference(x => x.InvitedUser).LoadAsync();

            var inviteDTO = MapToEventInviteDTO(invite);
            return Ok(inviteDTO);
        }

        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetInvitesByUser(string userId)
        {
            var invites = await _context.EventInvites
                .Include(ei => ei.Event)
                    .ThenInclude(e => e.Category)
                .Include(ei => ei.Event)
                    .ThenInclude(e => e.CreatedByNavigation)
                .Include(ei => ei.InvitedUser)
                .Where(ei => ei.InvitedUserId == userId)
                .ToListAsync();

            var inviteDTOs = invites.Select(ei => MapToEventInviteDTO(ei)).ToList();
            return Ok(inviteDTOs);
        }

        [HttpGet("pending/user/{userId}")]
        public async Task<IActionResult> GetPendingInvitesByUser(string userId)
        {
            var invites = await _context.EventInvites
                .Include(ei => ei.Event)
                    .ThenInclude(e => e.Category)
                .Include(ei => ei.Event)
                    .ThenInclude(e => e.CreatedByNavigation)
                .Include(ei => ei.InvitedUser)
                .Where(ei => ei.InvitedUserId == userId && ei.Status == InviteStatus.Pending)
                .ToListAsync();

            var inviteDTOs = invites.Select(ei => MapToEventInviteDTO(ei)).ToList();
            return Ok(inviteDTOs);
        }

        [HttpDelete("{inviteId}")]
        public async Task<IActionResult> DeleteInvite(string inviteId)
        {
            var invite = await _context.EventInvites.FindAsync(inviteId);
            if (invite == null)
            {
                return NotFound();
            }

            _context.EventInvites.Remove(invite);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private static EventInviteDTO MapToEventInviteDTO(EventInvite ei)
        {
            return new EventInviteDTO
            {
                Id = ei.Id,
                EventId = ei.EventId,
                InvitedUserId = ei.InvitedUserId,
                InvitedUser = ei.InvitedUser != null ? new UserDTO
                {
                    UserId = ei.InvitedUser.UserId,
                    Name = ei.InvitedUser.Name,
                    Email = ei.InvitedUser.Email,
                    Phone = ei.InvitedUser.Phone,
                    Address = ei.InvitedUser.Address,
                    DateOfBirth = ei.InvitedUser.DateOfBirth,
                    IsActive = ei.InvitedUser.IsActive
                } : null,
                Status = ei.Status.ToString(),
                ParticipantCount = ei.ParticipantCount,
                CreatedAt = ei.CreatedAt,
                UpdatedAt = ei.UpdatedAt,
                Event = ei.Event != null ? new EventDTO
                {
                    Id = ei.Event.Id,
                    Title = ei.Event.Title,
                    Description = ei.Event.Description,
                    StartDateTime = ei.Event.StartDateTime,
                    EndDateTime = ei.Event.EndDateTime,
                    Address = ei.Event.Address,
                    Latitude = ei.Event.Latitude,
                    Longitude = ei.Event.Longitude,
                    PickedFromMap = ei.Event.PickedFromMap,
                    CategoryId = ei.Event.CategoryId,
                    Category = ei.Event.Category != null ? new CategoryDTO
                    {
                        CategoryId = ei.Event.Category.CategoryId,
                        Name = ei.Event.Category.Name,
                        Description = ei.Event.Category.Description,
                        Color = ei.Event.Category.Color,
                        Icon = ei.Event.Category.Icon,
                        IsActive = ei.Event.Category.IsActive
                    } : null,
                    EventType = ei.Event.EventType,
                    MaxCapacity = ei.Event.MaxCapacity,
                    IsCancelled = ei.Event.IsCancelled,
                    IsCompleted = ei.Event.IsCompleted,
                    IsVisible = ei.Event.IsVisible,
                    CreatedBy = ei.Event.CreatedBy,
                    CreatedByUser = ei.Event.CreatedByNavigation != null ? new UserDTO
                    {
                        UserId = ei.Event.CreatedByNavigation.UserId,
                        Name = ei.Event.CreatedByNavigation.Name,
                        Email = ei.Event.CreatedByNavigation.Email,
                        Phone = ei.Event.CreatedByNavigation.Phone,
                        Address = ei.Event.CreatedByNavigation.Address,
                        DateOfBirth = ei.Event.CreatedByNavigation.DateOfBirth,
                        IsActive = ei.Event.CreatedByNavigation.IsActive
                    } : null,
                    CreatedAt = ei.Event.CreatedAt,
                    UpdatedAt = ei.Event.UpdatedAt
                } : null
            };
        }
    }
}
