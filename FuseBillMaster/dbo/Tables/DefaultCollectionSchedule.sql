CREATE TABLE [dbo].[DefaultCollectionSchedule] (
    [Id]  BIGINT IDENTITY (1, 1) NOT NULL,
    [Day] INT    NOT NULL,
    CONSTRAINT [PK_DefaultCollectionSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

