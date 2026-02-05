CREATE TABLE [dbo].[AccountGatewayReconciliation] (
    [Id]                   BIGINT   NOT NULL,
    [CountOfPending]       INT      NOT NULL,
    [CountOfSuccessful]    INT      NOT NULL,
    [CountOfFailed]        INT      NOT NULL,
    [LastCheckedTimestamp] DATETIME NULL,
    [NextCheckTimestamp]   DATETIME NULL,
    [CreatedTimestamp]     DATETIME NOT NULL,
    [ModifiedTimestamp]    DATETIME NOT NULL,
    CONSTRAINT [PK_AccountGatewayReconciliation] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountGatewayReconciliation_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id])
);


GO

