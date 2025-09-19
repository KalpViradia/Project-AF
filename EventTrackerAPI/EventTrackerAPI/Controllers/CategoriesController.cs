using Microsoft.AspNetCore.Mvc;
using EventTrackerAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace EventTrackerAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CategoriesController : ControllerBase
    {
        private readonly EventTrackerDbContext _context;
        public CategoriesController(EventTrackerDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public IActionResult GetAllCategories()
        {
            var categories = _context.Categories.ToList();
            return Ok(categories);
        }

        [HttpGet("active")]
        public IActionResult GetActiveCategories()
        {
            var categories = _context.Categories.Where(c => c.IsActive == 1).ToList();
            return Ok(categories);
        }
    }
}
