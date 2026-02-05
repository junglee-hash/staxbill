CREATE TABLE [dbo].[ReverseEarning] (
    [Id]              BIGINT         NOT NULL,
    [ReverseChargeId] BIGINT         NOT NULL,
    [Reference]       NVARCHAR (500) NULL,
    CONSTRAINT [PK_ReverseEarning] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ReverseEarning_ReverseCharge] FOREIGN KEY ([ReverseChargeId]) REFERENCES [dbo].[ReverseCharge] ([Id]),
    CONSTRAINT [FK_ReverseEarning_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_ReverseEarning_ReverseChargeId]
    ON [dbo].[ReverseEarning]([ReverseChargeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

