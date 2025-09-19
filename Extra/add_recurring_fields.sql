-- Add recurring event fields to Events table
-- Run this SQL script manually in your database to fix the 500 errors

ALTER TABLE Events ADD IsRecurring bit NOT NULL DEFAULT 0;
ALTER TABLE Events ADD RecurrenceType nvarchar(20) NULL;
ALTER TABLE Events ADD RecurrenceInterval int NOT NULL DEFAULT 1;
ALTER TABLE Events ADD RecurrenceEndDate datetime2 NULL;
ALTER TABLE Events ADD ParentEventId nvarchar(450) NULL;

-- Verify the columns were added
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Events' 
AND COLUMN_NAME IN ('IsRecurring', 'RecurrenceType', 'RecurrenceInterval', 'RecurrenceEndDate', 'ParentEventId');
