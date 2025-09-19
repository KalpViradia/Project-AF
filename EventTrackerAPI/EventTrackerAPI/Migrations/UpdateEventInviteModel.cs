using Microsoft.EntityFrameworkCore.Migrations;

namespace EventTrackerAPI.Migrations
{
    public partial class UpdateEventInviteModel : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // First drop the old table
            migrationBuilder.DropTable(
                name: "EventInvites");

            // Create new table with updated schema
            migrationBuilder.CreateTable(
                name: "EventInvites",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    EventId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    InvitedUserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "(getutcdate())"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EventInvites", x => x.Id);
                    table.ForeignKey(
                        name: "FK_EventInvites_Events_EventId",
                        column: x => x.EventId,
                        principalTable: "Events",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_EventInvites_Users_InvitedUserId",
                        column: x => x.InvitedUserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_EventInvites_EventId",
                table: "EventInvites",
                column: "EventId");

            migrationBuilder.CreateIndex(
                name: "IX_EventInvites_InvitedUserId",
                table: "EventInvites",
                column: "InvitedUserId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "EventInvites");

            // Recreate the original table
            migrationBuilder.CreateTable(
                name: "EventInvites",
                columns: table => new
                {
                    InviteId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    EventId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Phone = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    Status = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    InvitedAt = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EventInvites", x => x.InviteId);
                    table.ForeignKey(
                        name: "FK_EventInvites_Events_EventId",
                        column: x => x.EventId,
                        principalTable: "Events",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_EventInvites_EventId",
                table: "EventInvites",
                column: "EventId");
        }
    }
}
