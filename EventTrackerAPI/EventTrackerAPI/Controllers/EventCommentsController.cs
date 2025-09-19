using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EventTrackerAPI.Models;
using EventTrackerAPI.DTOs;
using EventTrackerAPI.Models.DTOs;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using System.IdentityModel.Tokens.Jwt;

namespace EventTrackerAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EventCommentsController : ControllerBase
    {
        private readonly EventTrackerDbContext _context;

        public EventCommentsController(EventTrackerDbContext context)
        {
            _context = context;
        }

        // GET: api/EventComments/event/{eventId}
        [HttpGet("event/{eventId}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetEventComments(string eventId, [FromQuery] string? commentType = null)
        {
            try
            {
                var conn = _context.Database.GetDbConnection();
                Console.WriteLine($"[EventComments] GET eventId={eventId}, DB={conn.DataSource}/{conn.Database}");
            }
            catch { }
            var query = _context.EventComments
                .Include(c => c.User)
                .Where(c => c.EventId == eventId && !c.IsDeleted)
                .AsQueryable();

            if (!string.IsNullOrEmpty(commentType))
            {
                query = query.Where(c => c.CommentType == commentType);
            }

            var comments = await query
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();

            var commentDTOs = comments.Select(c => MapToEventCommentDTO(c)).ToList();
            return Ok(commentDTOs);
        }

        // POST: api/EventComments
        [HttpPost]
        [AllowAnonymous]
        public async Task<IActionResult> CreateComment([FromBody] EventCommentCreateRequest request)
        {
            try
            {
                var suppliedUserId = string.IsNullOrWhiteSpace(request.UserId) ? null : request.UserId;
                var userId = suppliedUserId ?? GetCurrentUserId();

                Console.WriteLine($"[EventComments] CreateComment called: eventId={request.EventId}, userId={userId}, type={request.CommentType}");

                if (string.IsNullOrWhiteSpace(request.EventId) || string.IsNullOrWhiteSpace(request.Content))
                {
                    Console.WriteLine("[EventComments] Invalid payload: missing EventId or Content");
                    return BadRequest(new { message = "EventId and Content are required" });
                }

                // Validate event exists
                var eventExists = await _context.Events.AnyAsync(e => e.Id == request.EventId);
                Console.WriteLine($"[EventComments] Event exists: {eventExists}");
                if (!eventExists)
                {
                    return BadRequest(new { message = "Event not found" });
                }

                // Validate user exists to prevent FK errors
                var userExists = await _context.Users.AnyAsync(u => u.UserId == userId);
                Console.WriteLine($"[EventComments] User exists: {userExists}");
                if (!userExists)
                {
                    return BadRequest(new { message = "User not found or not logged in" });
                }

                // Check if user is event creator for announcements
                if (request.CommentType == "announcement")
                {
                    var eventObj = await _context.Events.FirstOrDefaultAsync(e => e.Id == request.EventId);
                    if (eventObj?.CreatedBy != userId)
                    {
                        Console.WriteLine("[EventComments] Forbid: non-creator attempted announcement");
                        return Forbid("Only event creators can post announcements");
                    }
                }

                var comment = new EventComment
                {
                    Id = Guid.NewGuid().ToString(),
                    EventId = request.EventId,
                    UserId = userId,
                    Content = request.Content,
                    CommentType = request.CommentType,
                    CreatedAt = DateTime.UtcNow
                };

                _context.EventComments.Add(comment);
                var affected = await _context.SaveChangesAsync();
                try
                {
                    var conn = _context.Database.GetDbConnection();
                    Console.WriteLine($"[EventComments] SaveChanges affected={affected}, DB={conn.DataSource}/{conn.Database}");
                }
                catch { }

                // Load the created comment with user details
                var createdComment = await _context.EventComments
                    .Include(c => c.User)
                    .FirstOrDefaultAsync(c => c.Id == comment.Id);

                var commentDTO = MapToEventCommentDTO(createdComment!);
                Console.WriteLine($"[EventComments] CreateComment success: id={comment.Id}");
                return CreatedAtAction(nameof(GetEventComments), new { eventId = request.EventId }, commentDTO);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[EventComments] CreateComment ERROR: {ex.Message}\n{ex.StackTrace}");
                return StatusCode(500, new { message = "Failed to create comment", error = ex.Message });
            }
        }

        // PUT: api/EventComments/{id}
        [HttpPut("{id}")]
        [AllowAnonymous]
        public async Task<IActionResult> UpdateComment(string id, [FromBody] EventCommentUpdateRequest request)
        {
            var userId = GetCurrentUserId();

            var comment = await _context.EventComments
                .Include(c => c.User)
                .FirstOrDefaultAsync(c => c.Id == id && !c.IsDeleted);

            if (comment == null)
            {
                return NotFound(new { message = "Comment not found" });
            }

            // Only comment author can update their comment
            if (comment.UserId != userId)
            {
                return StatusCode(403, new { message = "You can only edit your own comments" });
            }

            comment.Content = request.Content;
            comment.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            var commentDTO = MapToEventCommentDTO(comment);
            return Ok(commentDTO);
        }

        // DELETE: api/EventComments/{id}
        [HttpDelete("{id}")]
        [AllowAnonymous]
        public async Task<IActionResult> DeleteComment(string id)
        {
            var userId = GetCurrentUserId();

            var comment = await _context.EventComments
                .Include(c => c.Event)
                .FirstOrDefaultAsync(c => c.Id == id && !c.IsDeleted);

            if (comment == null)
            {
                return NotFound(new { message = "Comment not found" });
            }

            // Only comment author or event creator can delete
            if (comment.UserId != userId && comment.Event.CreatedBy != userId)
            {
                return StatusCode(403, new { message = "You can only delete your own comments or comments on your events" });
            }

            comment.IsDeleted = true;
            comment.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return NoContent();
        }

        private string ExtractUserIdFromToken(string token)
        {
            try
            {
                var handler = new JwtSecurityTokenHandler();
                var jsonToken = handler.ReadJwtToken(token);
                // Try common claim types in priority order
                var fromNameId = jsonToken.Claims.FirstOrDefault(x => x.Type == ClaimTypes.NameIdentifier)?.Value;
                var fromSub = jsonToken.Claims.FirstOrDefault(x => x.Type == JwtRegisteredClaimNames.Sub)?.Value;
                var fromCustom = jsonToken.Claims.FirstOrDefault(x => x.Type == "userId")?.Value;
                return fromNameId ?? fromSub ?? fromCustom ?? "";
            }
            catch
            {
                return "";
            }
        }

        private string GetCurrentUserId()
        {
            // Get user ID from JWT token or Authorization header
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                         ?? User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value
                         ?? User.FindFirst("userId")?.Value;
            
            // If no JWT token, try to extract from Authorization header manually
            if (string.IsNullOrEmpty(userId))
            {
                var authHeader = Request.Headers["Authorization"].FirstOrDefault();
                if (!string.IsNullOrEmpty(authHeader) && authHeader.StartsWith("Bearer "))
                {
                    var token = authHeader.Substring("Bearer ".Length).Trim();
                    userId = ExtractUserIdFromToken(token);
                }
            }
            
            // Fallback for testing - use the logged in user ID
            if (string.IsNullOrEmpty(userId))
            {
                userId = "ff6ad079-2a73-4738-b9f0-e00430e00528"; // Default to current user for testing
            }
            
            return userId;
        }

        private EventCommentDTO MapToEventCommentDTO(EventComment comment)
        {
            // Ensure DateTime kinds are explicit to avoid client-side skew
            // All timestamps are stored as UTC in the database (we set them using DateTime.UtcNow),
            // but EF may materialize them with Kind = Unspecified. Treat Unspecified as UTC.
            DateTime createdOut = comment.CreatedAt.Kind == DateTimeKind.Utc
                ? comment.CreatedAt
                : DateTime.SpecifyKind(comment.CreatedAt, DateTimeKind.Utc);

            DateTime? updatedOut = comment.UpdatedAt.HasValue
                ? (comment.UpdatedAt.Value.Kind == DateTimeKind.Utc
                    ? comment.UpdatedAt.Value
                    : DateTime.SpecifyKind(comment.UpdatedAt.Value, DateTimeKind.Utc))
                : null;

            return new EventCommentDTO
            {
                Id = comment.Id,
                EventId = comment.EventId,
                UserId = comment.UserId,
                Content = comment.Content,
                CommentType = comment.CommentType,
                CreatedAt = createdOut,
                UpdatedAt = updatedOut,
                User = new UserDTO
                {
                    UserId = comment.User.UserId,
                    Name = comment.User.Name,
                    Email = comment.User.Email,
                    Phone = comment.User.Phone,
                    Address = comment.User.Address,
                    DateOfBirth = comment.User.DateOfBirth,
                    IsActive = comment.User.IsActive
                }
            };
        }
    }
}
