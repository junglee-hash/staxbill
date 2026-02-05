CREATE TABLE [dbo].[SalesforceOpportunityPurchase] (
    [Id]                      BIGINT   IDENTITY (1, 1) NOT NULL,
    [SalesforceOpportunityId] BIGINT   NOT NULL,
    [PurchaseId]              BIGINT   NULL,
    [CreatedTimestamp]        DATETIME CONSTRAINT [DF_SalesforceOpportunityPurchaseCreatedTimestamp] DEFAULT ('1900-01-01') NOT NULL,
    CONSTRAINT [PK_SalesforceOpportunityPurchase] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SalesforceOpportunityPurchase_Purchase] FOREIGN KEY ([PurchaseId]) REFERENCES [dbo].[Purchase] ([Id]),
    CONSTRAINT [FK_SalesforceOpportunityPurchase_SalesforceOpportunity] FOREIGN KEY ([SalesforceOpportunityId]) REFERENCES [dbo].[SalesforceOpportunity] ([Id])
);


GO

