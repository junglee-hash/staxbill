CREATE TABLE [dbo].[EarningOpeningDeferredRevenue] (
    [Id]                       BIGINT         NOT NULL,
    [OpeningDeferredRevenueId] BIGINT         NOT NULL,
    [Reference]                NVARCHAR (500) NULL,
    CONSTRAINT [PK_EarningOpeningDeferredRevenue] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EarningOpeningDeferredRevenue_OpeningDeferredRevenue] FOREIGN KEY ([OpeningDeferredRevenueId]) REFERENCES [dbo].[OpeningDeferredRevenue] ([Id]),
    CONSTRAINT [FK_EarningOpeningDeferredRevenue_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

