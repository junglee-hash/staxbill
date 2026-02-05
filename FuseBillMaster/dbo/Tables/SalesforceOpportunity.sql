CREATE TABLE [dbo].[SalesforceOpportunity] (
    [Id]                          BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]                   BIGINT         NOT NULL,
    [SalesforceAccountId]         NVARCHAR (255) NOT NULL,
    [SalesforceOpportunityId]     NVARCHAR (255) NOT NULL,
    [SalesforceContactId]         NVARCHAR (255) NULL,
    [Activate]                    BIT            NOT NULL,
    [FusebillId]                  BIGINT         NULL,
    [SubscriptionId]              BIGINT         NULL,
    [SalesforceOpportunityStatus] INT            NOT NULL,
    [ErrorMessage]                VARCHAR (500)  NULL,
    [CreatedTimestamp]            DATETIME       CONSTRAINT [DF_SalesforceOpportunityCreatedTimestamp] DEFAULT ('1900-01-01') NOT NULL,
    [ActiveRecord]                BIT            CONSTRAINT [DF_SalesforceOpportunityActiveRecord] DEFAULT ((1)) NOT NULL,
    [IsCreatingCustomer]          BIT            CONSTRAINT [DF_SalesforceOpportunityIsCreatingCustomer] DEFAULT ((1)) NOT NULL,
    [CouponCodes]                 NVARCHAR (500) NULL,
    [ScheduledActivationDate]     DATETIME       NULL,
    CONSTRAINT [PK_SalesforceOpportunity] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_SalesforceOpportunity_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_SalesforceOpportunity_Status] FOREIGN KEY ([SalesforceOpportunityStatus]) REFERENCES [Lookup].[SalesforceOpportunityStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_SalesforceOpportunity_AccountId]
    ON [dbo].[SalesforceOpportunity]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

