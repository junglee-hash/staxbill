CREATE TABLE [dbo].[PlanFamilyPlan] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [PlanFamilyId]     BIGINT   NOT NULL,
    [PlanId]           BIGINT   NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_PlanFamilyPlan] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PlanFamilyPlan_Plan] FOREIGN KEY ([PlanId]) REFERENCES [dbo].[Plan] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_PlanFamilyPlan_PlanFamily] FOREIGN KEY ([PlanFamilyId]) REFERENCES [dbo].[PlanFamily] ([Id])
);


GO

