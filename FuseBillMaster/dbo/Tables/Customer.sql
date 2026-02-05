CREATE TABLE [dbo].[Customer] (
    [Id]                                  BIGINT         IDENTITY (1, 1) NOT NULL,
    [FirstName]                           NVARCHAR (50)  NULL,
    [MiddleName]                          NVARCHAR (50)  NULL,
    [LastName]                            NVARCHAR (50)  NULL,
    [Suffix]                              NVARCHAR (50)  NULL,
    [PrimaryEmail]                        VARCHAR (255)  NULL,
    [PrimaryPhone]                        VARCHAR (50)   NULL,
    [SecondaryEmail]                      VARCHAR (255)  NULL,
    [SecondaryPhone]                      VARCHAR (50)   NULL,
    [TitleId]                             INT            NULL,
    [Reference]                           NVARCHAR (255) NULL,
    [AccountId]                           BIGINT         NOT NULL,
    [CreatedTimestamp]                    DATETIME       NOT NULL,
    [ModifiedTimestamp]                   DATETIME       NOT NULL,
    [EffectiveTimestamp]                  DATETIME       NOT NULL,
    [ActivationTimestamp]                 DATETIME       NULL,
    [CancellationTimestamp]               DATETIME       NULL,
    [CompanyName]                         NVARCHAR (255) NULL,
    [CurrencyId]                          BIGINT         NOT NULL,
    [MonthlyRecurringRevenue]             MONEY          CONSTRAINT [DF_Customer_MonthlyRecurringRevenue] DEFAULT ((0)) NOT NULL,
    [SalesforceId]                        NVARCHAR (255) NULL,
    [ActivationDay]                       TINYINT        NULL,
    [NetMRR]                              MONEY          NOT NULL,
    [StatusId]                            INT            NOT NULL,
    [AccountStatusId]                     INT            NOT NULL,
    [ArBalance]                           MONEY          DEFAULT ((0)) NOT NULL,
    [NetsuiteId]                          NVARCHAR (255) NULL,
    [NextBillingDate]                     DATETIME       NULL,
    [NetsuiteEntityTypeId]                INT            NULL,
    [SalesforceAccountTypeId]             TINYINT        NULL,
    [SalesforceSynchStatusId]             TINYINT        CONSTRAINT [DF_CustomerSalesforceSynchStatus] DEFAULT ((1)) NOT NULL,
    [CurrentMrr]                          MONEY          DEFAULT ((0)) NOT NULL,
    [CurrentNetMrr]                       MONEY          DEFAULT ((0)) NOT NULL,
    [ParentId]                            BIGINT         NULL,
    [QuickBooksLatchTypeId]               TINYINT        NULL,
    [QuickBooksSyncToken]                 BIGINT         NULL,
    [QuickBooksId]                        BIGINT         NULL,
    [QuickBooksSyncTimestamp]             DATETIME       NULL,
    [NetsuiteSynchStatusId]               TINYINT        CONSTRAINT [DF_CustomerNetsuiteSynchStatus] DEFAULT ((2)) NOT NULL,
    [NetsuiteSyncTimestamp]               DATETIME       NULL,
    [CollectionLikelihood]                TINYINT        NULL,
    [CollectionLikelihoodTimestamp]       DATETIME       CONSTRAINT [DF_Customer_CollectionLikelihoodTimestamp_NULL] DEFAULT (NULL) NULL,
    [HasUnknownPayment]                   BIT            CONSTRAINT [DF_HasUnknownPayment] DEFAULT ((0)) NOT NULL,
    [RequiresProjectedInvoiceGeneration]  BIT            CONSTRAINT [DF_RequiresProjectedInvoiceGeneration] DEFAULT ((0)) NOT NULL,
    [RequiresFinancialCalendarGeneration] BIT            CONSTRAINT [DF_RequiresFinancialCalendarGeneration] DEFAULT ((0)) NOT NULL,
    [IsDeleted]                           BIT            CONSTRAINT [DF_Customer_IsDeleted] DEFAULT ('FALSE') NOT NULL,
    [IsParent]                            BIT            CONSTRAINT [DF_IsParent] DEFAULT ((0)) NOT NULL,
    [LastStatusJournalTimestamp]          DATETIME       NULL,
    [LastAccountStatusJournalTimestamp]   DATETIME       NULL,
    [NetsuiteLocationId]                  VARCHAR (100)  NULL,
    [SageIntacctLatchTypeId]              TINYINT        NULL,
    [SageIntacctId]                       BIGINT         NULL,
    [SageIntacctCustomerId]               BIGINT         NULL,
    [SageIntacctSyncTimestamp]            DATETIME       NULL,
    [AvalaraId]                           NVARCHAR (255) NULL,
    [AnrokCustomerId]                     NVARCHAR (255) NULL,
    CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Customer_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_Customer_CollectionLikelihood] FOREIGN KEY ([CollectionLikelihood]) REFERENCES [Lookup].[CollectionLikelihood] ([Id]),
    CONSTRAINT [FK_Customer_NetsuiteEntity] FOREIGN KEY ([NetsuiteEntityTypeId]) REFERENCES [Lookup].[NetsuiteEntityType] ([Id]),
    CONSTRAINT [FK_Customer_NetsuiteSynchStatus] FOREIGN KEY ([NetsuiteSynchStatusId]) REFERENCES [Lookup].[SalesforceSynchStatus] ([Id]),
    CONSTRAINT [FK_Customer_Parent] FOREIGN KEY ([ParentId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_Customer_SageIntacctLatchType] FOREIGN KEY ([SageIntacctLatchTypeId]) REFERENCES [Lookup].[SageIntacctLatchType] ([Id]),
    CONSTRAINT [FK_Customer_SalesforceAccountType] FOREIGN KEY ([SalesforceAccountTypeId]) REFERENCES [Lookup].[SalesforceAccountType] ([Id]),
    CONSTRAINT [FK_Customer_SalesforceSynchStatus] FOREIGN KEY ([SalesforceSynchStatusId]) REFERENCES [Lookup].[SalesforceSynchStatus] ([Id]),
    CONSTRAINT [FK_Customer_Title] FOREIGN KEY ([TitleId]) REFERENCES [Lookup].[Title] ([Id]),
    CONSTRAINT [FK_CustomerCurrencyId_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_Customer_SalesforceAccountTypeId]
    ON [dbo].[Customer]([SalesforceAccountTypeId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Customer_ParentId_AccountId]
    ON [dbo].[Customer]([ParentId] ASC, [AccountId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [COVIX_Customer_AccountId_IsDeleted]
    ON [dbo].[Customer]([AccountId] ASC, [IsDeleted] ASC)
    INCLUDE([Id], [CompanyName], [PrimaryEmail], [Reference], [FirstName], [LastName]);


GO

CREATE NONCLUSTERED INDEX [IX_Customer_AccountId_CurrencyId]
    ON [dbo].[Customer]([AccountId] ASC, [CurrencyId] ASC)
    INCLUDE([Id], [CreatedTimestamp], [ActivationTimestamp], [CancellationTimestamp], [MonthlyRecurringRevenue]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [COVIX_Customer_QuickbooksFiltering01]
    ON [dbo].[Customer]([QuickBooksId] ASC)
    INCLUDE([Id], [QuickBooksSyncTimestamp]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Customer_Reference_AccountId]
    ON [dbo].[Customer]([Reference] ASC, [AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Customer_CurrencyId]
    ON [dbo].[Customer]([CurrencyId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Customer_AccountId_StatusId_AccountStatusId_ParentId_Reference]
    ON [dbo].[Customer]([AccountId] ASC, [StatusId] ASC, [AccountStatusId] ASC, [ParentId] ASC, [Reference] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FIX_Customer_AccountId_QuickbooksSyncTimestamp_INCL]
    ON [dbo].[Customer]([AccountId] ASC, [QuickBooksSyncTimestamp] ASC)
    INCLUDE([QuickBooksId]) WHERE ([QuickBooksId] IS NOT NULL) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Customer_StatusId]
    ON [dbo].[Customer]([StatusId] ASC)
    INCLUDE([Id], [AccountId], [NetMRR], [ActivationTimestamp]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Customer_IsDeleted]
    ON [dbo].[Customer]([IsDeleted] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Customer_AccountStatusId_StatusId]
    ON [dbo].[Customer]([AccountStatusId] ASC, [StatusId] ASC)
    INCLUDE([Id], [AccountId]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

