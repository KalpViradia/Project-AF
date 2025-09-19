-- Add ParticipantCount column to EventInvites table
-- This is the manual SQL equivalent of the migration

USE [EventTrackerDB]  -- Replace with your actual database name
GO

-- Check if column already exists
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[EventInvites]') AND name = 'ParticipantCount')
BEGIN
    ALTER TABLE [dbo].[EventInvites]
    ADD [ParticipantCount] int NOT NULL DEFAULT 1
    
    PRINT 'ParticipantCount column added successfully'
END
ELSE
BEGIN
    PRINT 'ParticipantCount column already exists'
END
GO
