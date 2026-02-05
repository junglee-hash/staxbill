CREATE TABLE [dbo].[DefaultEmailSchedule] (
    [Id]           BIGINT       IDENTITY (1, 1) NOT NULL,
    [Type]         VARCHAR (50) NOT NULL,
    [DaysFromTerm] INT          NOT NULL,
    CONSTRAINT [PK_DefaultEmailSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

