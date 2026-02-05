CREATE TABLE [dbo].[AccountSalesforceOpportunityFieldMapping] (
    [Id]                         BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]                  BIGINT         NOT NULL,
    [FusebillFieldId]            INT            NOT NULL,
    [SalesforceFieldId]          INT            NOT NULL,
    [SalesforceCustomField]      NVARCHAR (255) NULL,
    [CreatedTimestamp]           DATETIME       NOT NULL,
    [SalesforceCustomLabelField] NVARCHAR (255) NULL,
    CONSTRAINT [PK_AccountSalesforceOpportunityFieldMapping] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountSalesforceOpportunityFieldMapping_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountSalesforceOpportunityFieldMapping_FusebillField] FOREIGN KEY ([FusebillFieldId]) REFERENCES [Lookup].[FusebillField] ([Id]),
    CONSTRAINT [FK_AccountSalesforceOpportunityFieldMapping_SalesforceField] FOREIGN KEY ([SalesforceFieldId]) REFERENCES [Lookup].[SalesforceField] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountSalesforceOpportunityFieldMapping_AccountId]
    ON [dbo].[AccountSalesforceOpportunityFieldMapping]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

