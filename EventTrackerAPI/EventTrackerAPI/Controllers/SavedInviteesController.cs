using Microsoft.AspNetCore.Mvc;
using EventTrackerAPI.Models;
using EventTrackerAPI.Models.DTOs;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace EventTrackerAPI.Controllers
{
    [ApiController]
    [Route("api/saved-invitees")]
    public class SavedInviteesController : ControllerBase
    {
        private readonly EventTrackerDbContext _context;
        public SavedInviteesController(EventTrackerDbContext context)
        {
            _context = context;
        }

        [HttpGet("{ownerUserId}")]
        public async Task<IActionResult> GetSavedInvitees(string ownerUserId)
        {
            var ownerExists = await _context.Users.AnyAsync(u => u.UserId == ownerUserId);
            if (!ownerExists)
            {
                return BadRequest(new { message = $"Owner user with ID {ownerUserId} does not exist" });
            }

            var saved = await _context.SavedInvitees
                .Where(si => si.OwnerUserId == ownerUserId)
                .Include(si => si.SavedUser)
                .Select(si => new UserDTO
                {
                    UserId = si.SavedUser.UserId,
                    Name = si.SavedUser.Name,
                    Email = si.SavedUser.Email,
                    Phone = si.SavedUser.Phone,
                    Address = si.SavedUser.Address,
                    DateOfBirth = si.SavedUser.DateOfBirth,
                    IsActive = si.SavedUser.IsActive
                })
                .ToListAsync();

            return Ok(saved);
        }

        public class SavedInviteeCreateRequest
        {
            public required string OwnerUserId { get; set; }
            public required string SavedUserId { get; set; }
        }

        [HttpPost]
        public async Task<IActionResult> AddSavedInvitee([FromBody] SavedInviteeCreateRequest req)
        {
            if (req.OwnerUserId == req.SavedUserId)
            {
                return BadRequest(new { message = "Cannot add yourself as a saved invitee" });
            }

            var owner = await _context.Users.FindAsync(req.OwnerUserId);
            var saved = await _context.Users.FindAsync(req.SavedUserId);
            if (owner == null || saved == null)
            {
                return BadRequest(new { message = "Owner or saved user not found" });
            }

            var exists = await _context.SavedInvitees
                .AnyAsync(si => si.OwnerUserId == req.OwnerUserId && si.SavedUserId == req.SavedUserId);
            if (exists)
            {
                return BadRequest(new { message = "This user is already in your invitees list" });
            }

            var entity = new SavedInvitee
            {
                OwnerUserId = req.OwnerUserId,
                SavedUserId = req.SavedUserId,
                CreatedAt = DateTime.UtcNow
            };
            _context.SavedInvitees.Add(entity);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Added" });
        }

        [HttpDelete("{ownerUserId}/{savedUserId}")]
        public async Task<IActionResult> RemoveSavedInvitee(string ownerUserId, string savedUserId)
        {
            var entity = await _context.SavedInvitees.FindAsync(ownerUserId, savedUserId);
            if (entity == null) return NotFound();

            _context.SavedInvitees.Remove(entity);
            await _context.SaveChangesAsync();
            return NoContent();
        }
    }
}
