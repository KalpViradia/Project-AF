using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace EventTrackerAPI.Models;

public partial class EventTrackerDbContext : DbContext
{
    public EventTrackerDbContext()
    {
    }

    public EventTrackerDbContext(DbContextOptions<EventTrackerDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Category> Categories { get; set; }

    public virtual DbSet<Event> Events { get; set; }

    public virtual DbSet<EventInvite> EventInvites { get; set; }
    public virtual DbSet<EventComment> EventComments { get; set; }
    public virtual DbSet<SavedInvitee> SavedInvitees { get; set; }

    public virtual DbSet<User> Users { get; set; }

    // Connection string is configured in Program.cs
    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            optionsBuilder.UseSqlServer("Server=KALP-VIRADIA\\SQLEXPRESS;Database=Event_Tracker_DB;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true");
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Event>(entity =>
        {
            entity.HasIndex(e => e.CategoryId, "IX_Events_CategoryId");

            entity.HasIndex(e => e.CreatedBy, "IX_Events_CreatedBy");

            entity.Property(e => e.Address).HasMaxLength(500);
            entity.Property(e => e.Latitude).HasColumnType("float").IsRequired(false);
            entity.Property(e => e.Longitude).HasColumnType("float").IsRequired(false);
            entity.Property(e => e.PickedFromMap).HasDefaultValue(false);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            entity.Property(e => e.Description).HasMaxLength(1000);
            entity.Property(e => e.EventType).HasMaxLength(100);
            entity.Property(e => e.IsVisible).HasDefaultValue(true);
            entity.Property(e => e.CommentsEnabled).HasDefaultValue(true);
            entity.Property(e => e.Title).HasMaxLength(200);
            
            // Recurring event properties
            entity.Property(e => e.IsRecurring).HasDefaultValue(false);
            entity.Property(e => e.RecurrenceType).HasMaxLength(20);
            entity.Property(e => e.RecurrenceInterval).HasDefaultValue(1);
            entity.Property(e => e.ParentEventId).HasMaxLength(450);

            entity.HasOne(d => d.Category).WithMany(p => p.Events)
                .HasForeignKey(d => d.CategoryId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.Events)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull);
        });

        modelBuilder.Entity<SavedInvitee>(entity =>
        {
            entity.ToTable("SavedInvitees");
            entity.HasKey(e => new { e.OwnerUserId, e.SavedUserId });

            entity.Property(e => e.OwnerUserId)
                .IsRequired()
                .HasColumnType("nvarchar(450)");

            entity.Property(e => e.SavedUserId)
                .IsRequired()
                .HasColumnType("nvarchar(450)");

            entity.Property(e => e.CreatedAt)
                .IsRequired()
                .HasColumnType("datetime2")
                .HasDefaultValueSql("GETUTCDATE()");

            entity.HasOne(d => d.OwnerUser)
                .WithMany(p => p.SavedInvitees)
                .HasForeignKey(d => d.OwnerUserId)
                .OnDelete(DeleteBehavior.NoAction);

            entity.HasOne(d => d.SavedUser)
                .WithMany()
                .HasForeignKey(d => d.SavedUserId)
                .OnDelete(DeleteBehavior.NoAction);

            entity.HasIndex(e => e.OwnerUserId)
                .HasDatabaseName("IX_SavedInvitees_OwnerUserId");

            entity.HasIndex(e => e.SavedUserId)
                .HasDatabaseName("IX_SavedInvitees_SavedUserId");
        });

        // EventUsers entity removed (deprecated). Use EventInvites for participation tracking.

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasIndex(e => e.Email, "IX_Users_Email").IsUnique();

            entity.Property(e => e.Address).HasMaxLength(500);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
            entity.Property(e => e.Email).HasMaxLength(150);
            entity.Property(e => e.IsActive).HasDefaultValue(1);
            entity.Property(e => e.IsLoggedIn).HasDefaultValue(false);
            entity.Property(e => e.Name).HasMaxLength(100);
            entity.Property(e => e.Password).HasMaxLength(255);
            entity.Property(e => e.Phone).HasMaxLength(20);
            entity.Property(e => e.CountryCode).HasMaxLength(10);
        });

        modelBuilder.Entity<EventInvite>(entity =>
        {
            entity.ToTable("EventInvites");
            
            entity.HasKey(e => e.Id);

            // Primary Key
            entity.Property(e => e.Id)
                .HasColumnType("nvarchar(450)")
                .ValueGeneratedNever();

            // Required fields
            entity.Property(e => e.EventId)
                .IsRequired()
                .HasColumnType("nvarchar(450)");

            entity.Property(e => e.InvitedUserId)
                .IsRequired()
                .HasColumnType("nvarchar(450)");

            entity.Property(e => e.Status)
                .IsRequired()
                .HasMaxLength(20)
                .HasColumnType("nvarchar(20)");

            entity.Property(e => e.ParticipantCount)
                .IsRequired()
                .HasColumnType("int")
                .HasDefaultValue(1);

            // Timestamps
            entity.Property(e => e.CreatedAt)
                .IsRequired()
                .HasColumnType("datetime2")
                .HasDefaultValueSql("GETUTCDATE()");

            entity.Property(e => e.UpdatedAt)
                .HasColumnType("datetime2")
                .IsRequired(false);

            // Relationships
            entity.HasOne(d => d.Event)
                .WithMany(p => p.EventInvites)
                .HasForeignKey(d => d.EventId)
                .OnDelete(DeleteBehavior.NoAction);

            entity.HasOne(d => d.InvitedUser)
                .WithMany()
                .HasForeignKey(d => d.InvitedUserId)
                .OnDelete(DeleteBehavior.NoAction);

            // Indexes
            entity.HasIndex(e => e.EventId)
                .HasDatabaseName("IX_EventInvites_EventId");

            entity.HasIndex(e => e.InvitedUserId)
                .HasDatabaseName("IX_EventInvites_InvitedUserId");
        });

        modelBuilder.Entity<EventComment>(entity =>
        {
            entity.ToTable("EventComments");
            
            entity.HasKey(e => e.Id);

            // Primary Key
            entity.Property(e => e.Id)
                .HasColumnType("nvarchar(450)")
                .ValueGeneratedNever();

            // Required fields
            entity.Property(e => e.EventId)
                .IsRequired()
                .HasColumnType("nvarchar(450)");

            entity.Property(e => e.UserId)
                .IsRequired()
                .HasColumnType("nvarchar(450)");

            entity.Property(e => e.Content)
                .IsRequired()
                .HasMaxLength(1000)
                .HasColumnType("nvarchar(1000)");

            entity.Property(e => e.CommentType)
                .IsRequired()
                .HasMaxLength(20)
                .HasColumnType("nvarchar(20)")
                .HasDefaultValue("comment");

            entity.Property(e => e.IsDeleted)
                .IsRequired()
                .HasColumnType("bit")
                .HasDefaultValue(false);

            // Timestamps
            entity.Property(e => e.CreatedAt)
                .IsRequired()
                .HasColumnType("datetime2")
                .HasDefaultValueSql("GETUTCDATE()");

            entity.Property(e => e.UpdatedAt)
                .HasColumnType("datetime2")
                .IsRequired(false);

            // Relationships
            entity.HasOne(d => d.Event)
                .WithMany()
                .HasForeignKey(d => d.EventId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(d => d.User)
                .WithMany()
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.NoAction);

            // Indexes
            entity.HasIndex(e => e.EventId)
                .HasDatabaseName("IX_EventComments_EventId");

            entity.HasIndex(e => e.UserId)
                .HasDatabaseName("IX_EventComments_UserId");

            entity.HasIndex(e => e.CreatedAt)
                .HasDatabaseName("IX_EventComments_CreatedAt");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
