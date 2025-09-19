-- Create EventComments table manually
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='EventComments' AND xtype='U')
BEGIN
    CREATE TABLE [dbo].[EventComments] (
        [Id] nvarchar(450) NOT NULL,
        [EventId] nvarchar(450) NOT NULL,
        [UserId] nvarchar(450) NOT NULL,
        [Content] nvarchar(1000) NOT NULL,
        [CommentType] nvarchar(20) NOT NULL DEFAULT 'comment',
        [CreatedAt] datetime2 NOT NULL DEFAULT GETUTCDATE(),
        [UpdatedAt] datetime2 NULL,
        [IsDeleted] bit NOT NULL DEFAULT 0,
        CONSTRAINT [PK_EventComments] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_EventComments_Events_EventId] FOREIGN KEY ([EventId]) REFERENCES [Events] ([Id]) ON DELETE CASCADE,
        CONSTRAINT [FK_EventComments_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([UserId])
    );
    
    CREATE INDEX [IX_EventComments_EventId] ON [EventComments] ([EventId]);
    CREATE INDEX [IX_EventComments_UserId] ON [EventComments] ([UserId]);
    CREATE INDEX [IX_EventComments_CreatedAt] ON [EventComments] ([CreatedAt]);
    
    PRINT 'EventComments table created successfully';
END
ELSE
BEGIN
    PRINT 'EventComments table already exists';
END

-- Add recurring event fields to Events table if they don't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Events]') AND name = 'IsRecurring')
BEGIN
    ALTER TABLE [dbo].[Events] ADD [IsRecurring] bit NOT NULL DEFAULT 0;
    PRINT 'Added IsRecurring column to Events table';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Events]') AND name = 'RecurrenceType')
BEGIN
    ALTER TABLE [dbo].[Events] ADD [RecurrenceType] nvarchar(20) NULL;
    PRINT 'Added RecurrenceType column to Events table';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Events]') AND name = 'RecurrenceInterval')
BEGIN
    ALTER TABLE [dbo].[Events] ADD [RecurrenceInterval] int NOT NULL DEFAULT 1;
    PRINT 'Added RecurrenceInterval column to Events table';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Events]') AND name = 'RecurrenceEndDate')
BEGIN
    ALTER TABLE [dbo].[Events] ADD [RecurrenceEndDate] datetime2 NULL;
    PRINT 'Added RecurrenceEndDate column to Events table';
END

IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Events]') AND name = 'ParentEventId')
BEGIN
    ALTER TABLE [dbo].[Events] ADD [ParentEventId] nvarchar(450) NULL;
    PRINT 'Added ParentEventId column to Events table';
END
