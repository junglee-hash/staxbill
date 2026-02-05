CREATE TABLE [dbo].[StaxGatewayFeeLogging] (
    [Id]                     BIGINT   IDENTITY (1, 1) NOT NULL,
    [AccountId]              BIGINT   NOT NULL,
    [StartDate]              DATETIME NULL,
    [EndDate]                DATETIME NULL,
    [CreatedTimestamp]       DATETIME NOT NULL,
    [ModifiedTimestamp]      DATETIME NOT NULL,
    [TotalBatches]           INT      NULL,
    [TotalRecords]           INT      NULL,
    [MatchedRecords]         INT      NULL,
    [UpdatedRecords]         INT      NULL,
    [ExecutionTimeInSeconds] INT      NULL,
    [Failed]                 BIT      NOT NULL,
    CONSTRAINT [PK_StaxGatewayFeeLogging] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_StaxGatewayFeeLogging_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]) ON DELETE CASCADE
);


GO

