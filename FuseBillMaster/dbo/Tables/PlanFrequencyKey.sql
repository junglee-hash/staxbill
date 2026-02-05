CREATE TABLE [dbo].[PlanFrequencyKey] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_PlanFrequencyKey] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

