CREATE TABLE [dbo].[BillingStatement] (
    [Id]                      BIGINT   IDENTITY (1, 1) NOT NULL,
    [CustomerId]              BIGINT   NOT NULL,
    [StartDate]               DATETIME NOT NULL,
    [EndDate]                 DATETIME NOT NULL,
    [OpeningBalance]          MONEY    NOT NULL,
    [ClosingBalance]          MONEY    NOT NULL,
    [CreatedTimestamp]        DATETIME NOT NULL,
    [StatementActivityTypeId] INT      CONSTRAINT [DF_BillingStatement_StatementActivityType] DEFAULT ((1)) NOT NULL,
    [StatementOptionId]       INT      CONSTRAINT [DF_BillingStatement_StatementOption] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_BillingStatement] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_BillingStatement_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_BillingStatement_StatementActivityType] FOREIGN KEY ([StatementActivityTypeId]) REFERENCES [Lookup].[StatementActivityType] ([Id]),
    CONSTRAINT [FK_BillingStatement_StatementOption] FOREIGN KEY ([StatementOptionId]) REFERENCES [Lookup].[BillingStatementOption] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_BillingStatement_CustomerId]
    ON [dbo].[BillingStatement]([CustomerId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

