CREATE TABLE [dbo].[ChargeLastEarning] (
    [Id]                        BIGINT   NOT NULL,
    [CreatedTimestamp]          DATETIME NOT NULL,
    [ModifiedTimestamp]         DATETIME NOT NULL,
    [EarningId]                 BIGINT   NULL,
    [EarningCompletedTimestamp] DATETIME NULL,
    [NextEarningTimestamp]      DATETIME NULL,
    [AccountId]                 BIGINT   NULL,
    [LastEarnedAmount]          MONEY    CONSTRAINT [DF_LastEarnedAmount] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ChargeEarningTimestamp] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ChargeEarningTimestamp_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_ChargeEarningTimestamp_Charge] FOREIGN KEY ([Id]) REFERENCES [dbo].[Charge] ([Id]),
    CONSTRAINT [FK_ChargeLastEarning_Earning] FOREIGN KEY ([EarningId]) REFERENCES [dbo].[Earning] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_ChargeLastEarning_EarningCompletedTimestamp_NextEarningTimestamp]
    ON [dbo].[ChargeLastEarning]([EarningCompletedTimestamp] ASC, [NextEarningTimestamp] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_ChargeLastEarning_Account_Incl]
    ON [dbo].[ChargeLastEarning]([AccountId] ASC, [EarningCompletedTimestamp] ASC, [NextEarningTimestamp] ASC)
    INCLUDE([Id], [EarningId]);


GO

