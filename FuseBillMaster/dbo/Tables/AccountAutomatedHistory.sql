CREATE TABLE [dbo].[AccountAutomatedHistory] (
    [Id]                            BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountId]                     BIGINT          NULL,
    [CreatedTimestamp]              DATETIME        NOT NULL,
    [ModifiedTimestamp]             DATETIME        NOT NULL,
    [CompletedTimestamp]            DATETIME        NULL,
    [TotalCustomers]                INT             NULL,
    [CustomersActioned]             INT             NULL,
    [AccountAutomatedHistoryTypeId] TINYINT         NOT NULL,
    [HasFinished]                   BIT             CONSTRAINT [DF_AccountAutomatedHistory_HasFinished] DEFAULT ((0)) NOT NULL,
    [Failures]                      NVARCHAR (1000) NULL,
    CONSTRAINT [PK_AccountAutomatedHistory] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountAutomatedHistory_AccountAutomatedHistoryType] FOREIGN KEY ([AccountAutomatedHistoryTypeId]) REFERENCES [Lookup].[AccountAutomatedHistoryType] ([Id])
);


GO

