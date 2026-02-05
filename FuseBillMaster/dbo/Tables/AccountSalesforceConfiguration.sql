CREATE TABLE [dbo].[AccountSalesforceConfiguration] (
    [Id]                                         BIGINT         NOT NULL,
    [DefaultAccountTypeId]                       TINYINT        NOT NULL,
    [CurrentPackageVersion]                      DECIMAL (3, 2) NULL,
    [StandardPriceBookId]                        VARCHAR (100)  NULL,
    [SyncCatalog]                                BIT            DEFAULT ((0)) NOT NULL,
    [CompletedWizard]                            BIT            DEFAULT ((1)) NOT NULL,
    [OrganizationName]                           VARCHAR (80)   NULL,
    [SalesforceCatalogSyncStatusId]              INT            DEFAULT ((1)) NOT NULL,
    [IsActive]                                   BIT            DEFAULT ((1)) NOT NULL,
    [IsMultiCurrency]                            BIT            DEFAULT ((1)) NOT NULL,
    [iFrameAllowSubscriptionActivation]          BIT            CONSTRAINT [DF_iFrameAllowSubscriptionActivation] DEFAULT ((1)) NOT NULL,
    [OneTimePurchsePriceBookId]                  VARCHAR (100)  NULL,
    [MaintainSubscriptionProductsInSalesforce]   BIT            CONSTRAINT [df_MaintainSubscriptionProductsInSalesforce] DEFAULT ((0)) NOT NULL,
    [CreateEmptySubscriptions]                   BIT            CONSTRAINT [DF_CreateEmptySubscriptions] DEFAULT ((1)) NOT NULL,
    [iFrameAllowSubscriptionCancellation]        BIT            CONSTRAINT [DF_AllowIFrameSubscriptionCancellation] DEFAULT ((0)) NOT NULL,
    [iFrameAllowPricingPermissions]              BIT            CONSTRAINT [DF_AllowPricingPermissions] DEFAULT ((0)) NOT NULL,
    [SalesforceSubscriptionProductsSyncOptionId] INT            CONSTRAINT [DF_SalesforceSubscriptionProductsSyncOptionId] DEFAULT ((3)) NOT NULL,
    CONSTRAINT [PK_AccountSalesforceConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountSalesforceConfiguration_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountSalesforceConfiguration_AccountType] FOREIGN KEY ([DefaultAccountTypeId]) REFERENCES [Lookup].[SalesforceAccountType] ([Id]),
    CONSTRAINT [FK_AccountSalesforceConfiguration_SalesforceCatalogSyncStatus] FOREIGN KEY ([SalesforceCatalogSyncStatusId]) REFERENCES [Lookup].[SalesforceCatalogSyncStatus] ([Id]),
    CONSTRAINT [FK_AccountSalesforceConfiguration_SalesforceSubscriptionProductsSyncOptionId] FOREIGN KEY ([SalesforceSubscriptionProductsSyncOptionId]) REFERENCES [Lookup].[SalesforceSubscriptionProductsSyncOption] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountSalesforceConfiguration_DefaultAccountTypeId]
    ON [dbo].[AccountSalesforceConfiguration]([DefaultAccountTypeId] ASC) WITH (FILLFACTOR = 100);


GO

