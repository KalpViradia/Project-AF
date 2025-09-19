using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EventTrackerAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddParticipantCountToEventInvite : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "ParticipantCount",
                table: "EventInvites",
                type: "int",
                nullable: false,
                defaultValue: 1);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ParticipantCount",
                table: "EventInvites");
        }
    }
}
