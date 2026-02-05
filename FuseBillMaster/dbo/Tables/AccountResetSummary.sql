CREATE TABLE [dbo].[AccountResetSummary] (
    [Id]                   BIGINT       IDENTITY (1, 1) NOT NULL,
    [AccountResetId]       BIGINT       NOT NULL,
    [EntityName]           VARCHAR (50) NOT NULL,
    [DatabaseInstanceId]   TINYINT      NOT NULL,
    [TotalCount]           INT          NOT NULL,
    [SuccessfulCount]      INT          NOT NULL,
    [ErrorCount]           INT          NOT NULL,
    [DeleteStartTimestamp] DATETIME     NOT NULL,
    [DeleteEndTimestamp]   DATETIME     NULL,
    CONSTRAINT [PK_AccountResetSummary] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountResetSummary_AccountReset] FOREIGN KEY ([AccountResetId]) REFERENCES [dbo].[AccountReset] ([Id]),
    CONSTRAINT [FK_AccountResetSummary_DatabaseInstance] FOREIGN KEY ([DatabaseInstanceId]) REFERENCES [Lookup].[ReportDatabaseInstance] ([Id])
);


GO

