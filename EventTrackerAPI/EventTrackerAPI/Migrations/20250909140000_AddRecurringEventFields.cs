using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EventTrackerAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddRecurringEventFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsRecurring",
                table: "Events",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "RecurrenceType",
                table: "Events",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RecurrenceInterval",
                table: "Events",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.AddColumn<DateTime>(
                name: "RecurrenceEndDate",
                table: "Events",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ParentEventId",
                table: "Events",
                type: "nvarchar(450)",
                maxLength: 450,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsRecurring",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "RecurrenceType",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "RecurrenceInterval",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "RecurrenceEndDate",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "ParentEventId",
                table: "Events");
        }
    }
}
