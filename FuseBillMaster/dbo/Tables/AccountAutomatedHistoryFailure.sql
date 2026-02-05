CREATE TABLE [dbo].[AccountAutomatedHistoryFailure] (
    [Id]                                BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]                         BIGINT         NULL,
    [CustomerId]                        BIGINT         NULL,
    [CreatedTimestamp]                  DATETIME       NOT NULL,
    [ModifiedTimestamp]                 DATETIME       NOT NULL,
    [AccountAutomatedHistoryTypeId]     TINYINT        NOT NULL,
    [AutomatedHistoryFailureCategoryId] TINYINT        NOT NULL,
    [ExceptionMessage]                  NVARCHAR (255) NULL,
    CONSTRAINT [PK_AccountAutomatedHistoryFailure] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountAutomatedHistoryFailure_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountAutomatedHistoryFailure_AccountAutomatedHistoryType] FOREIGN KEY ([AccountAutomatedHistoryTypeId]) REFERENCES [Lookup].[AccountAutomatedHistoryType] ([Id]),
    CONSTRAINT [FK_AccountAutomatedHistoryFailure_AutomatedHistoryFailureCategory] FOREIGN KEY ([AutomatedHistoryFailureCategoryId]) REFERENCES [Lookup].[AutomatedHistoryFailureCategory] ([Id]),
    CONSTRAINT [FK_AccountAutomatedHistoryFailure_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]) ON DELETE CASCADE
);


GO

