using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EventTrackerAPI.Migrations
{
    /// <inheritdoc />
    public partial class UpdateEventInviteToUseUsers : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_EventInvites_Events_EventId",
                table: "EventInvites");

            migrationBuilder.DropPrimaryKey(
                name: "PK_EventInvites",
                table: "EventInvites");

            migrationBuilder.DropColumn(
                name: "InvitedAt",
                table: "EventInvites");

            migrationBuilder.DropColumn(
                name: "Phone",
                table: "EventInvites");

            migrationBuilder.RenameColumn(
                name: "InviteId",
                table: "EventInvites",
                newName: "InvitedUserId");

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedAt",
                table: "Users",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "GETUTCDATE()",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "(getutcdate())");

            migrationBuilder.AlterColumn<DateTime>(
                name: "InvitedAt",
                table: "EventUsers",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "GETUTCDATE()",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "(getutcdate())");

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedAt",
                table: "Events",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "GETUTCDATE()",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "(getutcdate())");

            migrationBuilder.AddColumn<string>(
                name: "Id",
                table: "EventInvites",
                type: "nvarchar(450)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "EventInvites",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "GETUTCDATE()");

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "EventInvites",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_EventInvites",
                table: "EventInvites",
                column: "Id");

            migrationBuilder.CreateIndex(
                name: "IX_EventInvites_InvitedUserId",
                table: "EventInvites",
                column: "InvitedUserId");

            migrationBuilder.AddForeignKey(
                name: "FK_EventInvites_Events_EventId",
                table: "EventInvites",
                column: "EventId",
                principalTable: "Events",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_EventInvites_Users_InvitedUserId",
                table: "EventInvites",
                column: "InvitedUserId",
                principalTable: "Users",
                principalColumn: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_EventInvites_Events_EventId",
                table: "EventInvites");

            migrationBuilder.DropForeignKey(
                name: "FK_EventInvites_Users_InvitedUserId",
                table: "EventInvites");

            migrationBuilder.DropPrimaryKey(
                name: "PK_EventInvites",
                table: "EventInvites");

            migrationBuilder.DropIndex(
                name: "IX_EventInvites_InvitedUserId",
                table: "EventInvites");

            migrationBuilder.DropColumn(
                name: "Id",
                table: "EventInvites");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "EventInvites");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "EventInvites");

            migrationBuilder.RenameColumn(
                name: "InvitedUserId",
                table: "EventInvites",
                newName: "InviteId");

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedAt",
                table: "Users",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "(getutcdate())",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "GETUTCDATE()");

            migrationBuilder.AlterColumn<DateTime>(
                name: "InvitedAt",
                table: "EventUsers",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "(getutcdate())",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "GETUTCDATE()");

            migrationBuilder.AlterColumn<DateTime>(
                name: "CreatedAt",
                table: "Events",
                type: "datetime2",
                nullable: false,
                defaultValueSql: "(getutcdate())",
                oldClrType: typeof(DateTime),
                oldType: "datetime2",
                oldDefaultValueSql: "GETUTCDATE()");

            migrationBuilder.AddColumn<string>(
                name: "InvitedAt",
                table: "EventInvites",
                type: "nvarchar(50)",
                maxLength: 50,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "Phone",
                table: "EventInvites",
                type: "nvarchar(20)",
                maxLength: 20,
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddPrimaryKey(
                name: "PK_EventInvites",
                table: "EventInvites",
                column: "InviteId");

            migrationBuilder.AddForeignKey(
                name: "FK_EventInvites_Events_EventId",
                table: "EventInvites",
                column: "EventId",
                principalTable: "Events",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
