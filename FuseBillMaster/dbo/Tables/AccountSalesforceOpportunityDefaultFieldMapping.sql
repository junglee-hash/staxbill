CREATE TABLE [dbo].[AccountSalesforceOpportunityDefaultFieldMapping] (
    [Id]                         BIGINT   IDENTITY (1, 1) NOT NULL,
    [AccountId]                  BIGINT   NOT NULL,
    [SalesforceDefaultMappingId] INT      NOT NULL,
    [IsContact]                  BIT      NOT NULL,
    [IsEnabled]                  BIT      DEFAULT ((1)) NOT NULL,
    [CreatedTimestamp]           DATETIME NOT NULL,
    CONSTRAINT [PK_AccountSalesforceOpportunityDefaultFieldMapping] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountSalesforceOpportunityDefaultFieldMapping_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountSalesforceOpportunityDefaultFieldMapping_SalesforceDefaultMapping] FOREIGN KEY ([SalesforceDefaultMappingId]) REFERENCES [Lookup].[SalesforceDefaultMappings] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountSalesforceOpportunityDefaultFieldMapping_AccountId]
    ON [dbo].[AccountSalesforceOpportunityDefaultFieldMapping]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

