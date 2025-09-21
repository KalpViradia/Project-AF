using EventTrackerAPI.Models;
using EventTrackerAPI.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

// Add JWT Authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = "event-tracker-api",
            ValidAudience = "event-tracker-client",
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes("your-super-secret-key-with-at-least-128-bits")
            )
        };
    });

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterWeb",
        builder =>
        {
            builder.SetIsOriginAllowed(origin =>
                {
                    // Allow localhost with any port for development
                    return origin.StartsWith("http://localhost:") || 
                           origin.StartsWith("https://localhost:") ||
                           origin.StartsWith("http://127.0.0.1:") ||
                           origin.StartsWith("https://127.0.0.1:");
                })
                .AllowAnyMethod()
                .AllowAnyHeader()
                .AllowCredentials();
        });
});

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull;
    });

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddDbContext<EventTrackerDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Register services
builder.Services.AddScoped<RecurringEventService>();

var app = builder.Build();

// Apply pending migrations automatically
using (var scope = app.Services.CreateScope())
{
    try
    {
        var context = scope.ServiceProvider.GetRequiredService<EventTrackerDbContext>();
        context.Database.Migrate();
        Console.WriteLine("Database migrations applied successfully.");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Migration failed: {ex.Message}");
        // Try to execute the SQL directly
        try
        {
            var context = scope.ServiceProvider.GetRequiredService<EventTrackerDbContext>();
            var sql = @"
                IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[EventInvites]') AND name = 'ParticipantCount')
                BEGIN
                    ALTER TABLE [dbo].[EventInvites]
                    ADD [ParticipantCount] int NOT NULL DEFAULT 1
                END";
            context.Database.ExecuteSqlRaw(sql);
            Console.WriteLine("ParticipantCount column added via direct SQL.");

            // Drop EventUsers table if it still exists (deprecation fallback)
            var dropEventUsersSql = @"
                IF OBJECT_ID(N'[dbo].[EventUsers]', 'U') IS NOT NULL
                BEGIN
                    DROP TABLE [dbo].[EventUsers]
                END";
            try
            {
                context.Database.ExecuteSqlRaw(dropEventUsersSql);
                Console.WriteLine("EventUsers table dropped via direct SQL.");
            }
            catch (Exception dropEx)
            {
                Console.WriteLine($"Direct SQL drop of EventUsers failed: {dropEx.Message}");
            }
        }
        catch (Exception sqlEx)
        {
            Console.WriteLine($"Direct SQL execution failed: {sqlEx.Message}");
        }
    }
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Enable CORS
app.UseCors("AllowFlutterWeb");

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
