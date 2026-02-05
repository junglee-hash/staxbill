CREATE TABLE [dbo].[PlanRevision] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    [PlanId]           BIGINT   NOT NULL,
    [IsActive]         BIT      NOT NULL,
    CONSTRAINT [PK_PlanRevision] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PlanRevision_PlanId] FOREIGN KEY ([PlanId]) REFERENCES [dbo].[Plan] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_PlanRevision_PlanId]
    ON [dbo].[PlanRevision]([PlanId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

