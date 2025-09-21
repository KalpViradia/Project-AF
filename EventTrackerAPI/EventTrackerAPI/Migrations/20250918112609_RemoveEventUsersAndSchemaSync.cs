using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EventTrackerAPI.Migrations
{
    /// <inheritdoc />
    public partial class RemoveEventUsersAndSchemaSync : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "EventUsers");

            migrationBuilder.AddColumn<bool>(
                name: "CommentsEnabled",
                table: "Events",
                type: "bit",
                nullable: false,
                defaultValue: true);

            migrationBuilder.CreateTable(
                name: "SavedInvitees",
                columns: table => new
                {
                    OwnerUserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    SavedUserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SavedInvitees", x => new { x.OwnerUserId, x.SavedUserId });
                    table.ForeignKey(
                        name: "FK_SavedInvitees_Users_OwnerUserId",
                        column: x => x.OwnerUserId,
                        principalTable: "Users",
                        principalColumn: "UserId");
                    table.ForeignKey(
                        name: "FK_SavedInvitees_Users_SavedUserId",
                        column: x => x.SavedUserId,
                        principalTable: "Users",
                        principalColumn: "UserId");
                });

            migrationBuilder.CreateIndex(
                name: "IX_SavedInvitees_OwnerUserId",
                table: "SavedInvitees",
                column: "OwnerUserId");

            migrationBuilder.CreateIndex(
                name: "IX_SavedInvitees_SavedUserId",
                table: "SavedInvitees",
                column: "SavedUserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SavedInvitees");

            migrationBuilder.DropColumn(
                name: "CommentsEnabled",
                table: "Events");

            migrationBuilder.CreateTable(
                name: "EventUsers",
                columns: table => new
                {
                    EventId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    UserId = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Adults = table.Column<int>(type: "int", nullable: false),
                    Children = table.Column<int>(type: "int", nullable: false),
                    InvitedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "GETUTCDATE()"),
                    Note = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    RespondedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Role = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Status = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EventUsers", x => new { x.EventId, x.UserId });
                    table.ForeignKey(
                        name: "FK_EventUsers_Events_EventId",
                        column: x => x.EventId,
                        principalTable: "Events",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_EventUsers_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_EventUsers_UserId",
                table: "EventUsers",
                column: "UserId");
        }
    }
}
