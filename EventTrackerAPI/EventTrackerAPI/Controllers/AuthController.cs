using Microsoft.AspNetCore.Mvc;
using EventTrackerAPI.Models;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace EventTrackerAPI.Controllers
{
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly EventTrackerDbContext _context;
        public AuthController(EventTrackerDbContext context)
        {
            _context = context;
        }

        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginRequest request)
        {
            var user = _context.Users.FirstOrDefault(u => u.Email == request.Email && u.Password == request.Password);
            if (user == null)
                return Unauthorized(new { message = "Invalid email or password" });
            if (user.IsActive != 1)
                return Unauthorized(new { message = "User is not active" });

            // Set user as logged in
            user.IsLoggedIn = true;
            user.LastLogin = DateTime.UtcNow;
            _context.SaveChanges();

            // Generate a simple JWT token (you should use proper JWT implementation in production)
            var token = GenerateJwtToken(user);

            return Ok(new { token = token, user = user });
        }

        [HttpPost("signup")]
        public IActionResult Signup([FromBody] SignupRequest request)
        {
            if (_context.Users.Any(u => u.Email == request.Email))
                return BadRequest(new { message = "Email already exists" });

            var user = new User
            {
                UserId = Guid.NewGuid().ToString(),
                Name = request.Name,
                Email = request.Email,
                Password = request.Password,
                Phone = request.Phone,
                Address = request.Address,
                DateOfBirth = request.DateOfBirth,
                IsActive = 1,
                CreatedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            _context.SaveChanges();
            return Ok(user);
        }

        [HttpPost("logout")]
        public IActionResult Logout([FromBody] LogoutRequest request)
        {
            if (!string.IsNullOrEmpty(request.Token))
            {
                var userId = ExtractUserIdFromToken(request.Token);
                if (!string.IsNullOrEmpty(userId))
                {
                    var user = _context.Users.FirstOrDefault(u => u.UserId == userId);
                    if (user != null)
                    {
                        user.IsLoggedIn = false;
                        _context.SaveChanges();
                    }
                }
            }
            return Ok(new { message = "Logged out" });
        }

        private string GenerateJwtToken(User user)
        {
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes("your-super-secret-key-with-at-least-128-bits"));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.UserId),
                new Claim(JwtRegisteredClaimNames.Email, user.Email),
                new Claim(JwtRegisteredClaimNames.Name, user.Name),
                new Claim("userId", user.UserId),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            };

            var token = new JwtSecurityToken(
                issuer: "event-tracker-api",
                audience: "event-tracker-client",
                claims: claims,
                expires: DateTime.Now.AddDays(7),
                signingCredentials: credentials
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        public class UpdateProfileRequest
        {
            public string UserId { get; set; } = string.Empty;
            public string Name { get; set; } = string.Empty;
            public string? Phone { get; set; }
            public string? Gender { get; set; }
            public string? DateOfBirth { get; set; }
            public string? Bio { get; set; }
        }

        [HttpPut("users/{userId}/update")]
        public IActionResult UpdateUser(string userId, [FromBody] UpdateProfileRequest request)
        {
            Console.WriteLine($"Received update request: {System.Text.Json.JsonSerializer.Serialize(request)}");

            if (userId != request.UserId)
                return BadRequest(new { message = "URL userId does not match request body userId" });

            var user = _context.Users.FirstOrDefault(u => u.UserId == request.UserId);
            if (user == null)
                return NotFound(new { message = "User not found" });

            // Update allowed fields
            user.Name = request.Name;
            user.Phone = request.Phone;
            user.Gender = request.Gender;
            user.DateOfBirth = !string.IsNullOrEmpty(request.DateOfBirth)
                ? DateTime.Parse(request.DateOfBirth)
                : null;
            user.Bio = request.Bio;

            try
            {
                _context.SaveChanges();
                return Ok(user);
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = "Failed to update user", error = ex.Message });
            }
        }

        [HttpGet("users/search")]
        public IActionResult SearchUsers([FromQuery] string? phone = null, [FromQuery] string? email = null, [FromQuery] string? name = null)
        {
            var query = _context.Users.Where(u => u.IsActive == 1);

            if (!string.IsNullOrEmpty(phone))
            {
                query = query.Where(u => u.Phone != null && u.Phone.Contains(phone));
            }

            if (!string.IsNullOrEmpty(email))
            {
                query = query.Where(u => u.Email.Contains(email));
            }

            if (!string.IsNullOrEmpty(name))
            {
                query = query.Where(u => u.Name.Contains(name));
            }

            var users = query.Select(u => new
            {
                u.UserId,
                u.Name,
                u.Email,
                u.Phone
            }).Take(10).ToList();

            return Ok(users);
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);
            if (user == null)
            {
                // Don't reveal if email exists or not for security
                return Ok(new { message = "If the email exists, a password reset link has been sent." });
            }

            // In a real application, you would:
            // 1. Generate a secure reset token
            // 2. Store it in database with expiration
            // 3. Send email with reset link
            // For now, we'll just return success
            return Ok(new { message = "Password reset instructions sent to your email." });
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            // In a real application, you would validate the token here
            // For now, we'll simulate a successful reset
            return Ok(new { message = "Password has been reset successfully." });
        }

        [HttpPut("update-password-direct")]
        public async Task<IActionResult> UpdatePasswordDirect([FromBody] UpdatePasswordRequest request)
        {
            try
            {
                // In a real application, you would:
                // 1. Verify the user's identity (through current session/token)
                // 2. Hash the new password
                // 3. Update the password in database
                // For now, we'll just return success
                return Ok(new { message = "Password updated successfully." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while updating the password.", error = ex.Message });
            }
        }

        [HttpPost("reset-password-direct")]
        public async Task<IActionResult> ResetPasswordDirect([FromBody] ResetPasswordDirectRequest request)
        {
            try
            {
                // First, verify the email exists
                var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == request.Email);
                if (user == null)
                {
                    return BadRequest(new { message = "Invalid email address." });
                }

                // Update the password directly (in production, you should hash the password)
                user.Password = request.NewPassword;
                await _context.SaveChangesAsync();

                return Ok(new { message = "Password has been reset successfully." });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred while resetting the password.", error = ex.Message });
            }
        }

        [HttpPost("auto-login")]
        public IActionResult AutoLogin([FromBody] AutoLoginRequest request)
        {
            try
            {
                User? user = null;

                // Check by userId first, then by email
                if (!string.IsNullOrEmpty(request.UserId))
                {
                    user = _context.Users.FirstOrDefault(u => u.UserId == request.UserId);
                }
                else if (!string.IsNullOrEmpty(request.Email))
                {
                    user = _context.Users.FirstOrDefault(u => u.Email == request.Email);
                }
                else
                {
                    return BadRequest(new { message = "UserId or Email is required", isLoggedIn = false });
                }

                if (user == null || user.IsActive != 1)
                {
                    return Unauthorized(new { message = "User not found or inactive", isLoggedIn = false });
                }

                if (!user.IsLoggedIn)
                {
                    return Unauthorized(new { message = "User is not logged in", isLoggedIn = false });
                }

                return Ok(new { 
                    message = "User is logged in", 
                    isLoggedIn = true, 
                    user = new { 
                        userId = user.UserId, 
                        name = user.Name, 
                        email = user.Email 
                    } 
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Error checking login status", error = ex.Message, isLoggedIn = false });
            }
        }

        [HttpGet("me")]
        public IActionResult GetCurrentUser()
        {
            try
            {
                var authHeader = Request.Headers["Authorization"].FirstOrDefault();
                if (string.IsNullOrEmpty(authHeader) || !authHeader.StartsWith("Bearer "))
                {
                    return Unauthorized(new { message = "Missing or invalid Authorization header" });
                }

                var token = authHeader.Substring("Bearer ".Length).Trim();
                var handler = new JwtSecurityTokenHandler();
                var jsonToken = handler.ReadJwtToken(token);

                var userId = jsonToken.Claims
                    .FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Sub || c.Type == "sub" || c.Type == "userId")?.Value;

                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "Invalid token: missing user identifier" });
                }

                var user = _context.Users.FirstOrDefault(u => u.UserId == userId);
                if (user == null)
                {
                    return NotFound(new { message = "User not found" });
                }

                return Ok(new
                {
                    userId = user.UserId,
                    name = user.Name,
                    email = user.Email,
                    phone = user.Phone,
                    address = user.Address,
                    dateOfBirth = user.DateOfBirth,
                    gender = user.Gender,
                    bio = user.Bio,
                    isActive = user.IsActive == 1,
                    createdAt = user.CreatedAt,
                    lastLogin = user.LastLogin
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "An error occurred.", error = ex.Message });
            }
        }

        public class LoginRequest
        {
            public required string Email { get; set; }
            public required string Password { get; set; }
        }

        public class SignupRequest
        {
            public required string Name { get; set; }
            public required string Email { get; set; }
            public required string Password { get; set; }
            public string? Phone { get; set; }
            public string? Address { get; set; }
            public DateTime? DateOfBirth { get; set; }
        }

        public class LogoutRequest
        {
            public string? Token { get; set; }
        }

        public class ForgotPasswordRequest
        {
            public required string Email { get; set; }
        }

        public class ResetPasswordRequest
        {
            public required string Token { get; set; }
            public required string NewPassword { get; set; }
        }

        public class UpdatePasswordRequest
        {
            public required string NewPassword { get; set; }
        }

        public class ResetPasswordDirectRequest
        {
            public required string Email { get; set; }
            public required string NewPassword { get; set; }
        }

        public class AutoLoginRequest
        {
            public string? UserId { get; set; }
            public string? Email { get; set; }
        }

        private string ExtractUserIdFromToken(string token)
        {
            try
            {
                var handler = new JwtSecurityTokenHandler();
                var jsonToken = handler.ReadJwtToken(token);
                return jsonToken.Claims.FirstOrDefault(x => x.Type == JwtRegisteredClaimNames.Sub || x.Type == "sub" || x.Type == "userId")?.Value ?? "";
            }
            catch
            {
                return "";
            }
        }
    }
}
