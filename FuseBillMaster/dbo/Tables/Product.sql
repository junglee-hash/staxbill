CREATE TABLE [dbo].[Product] (
    [Id]                            BIGINT          IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]              DATETIME        NOT NULL,
    [ModifiedTimestamp]             DATETIME        NOT NULL,
    [Code]                          NVARCHAR (1000) NOT NULL,
    [Name]                          NVARCHAR (100)  NOT NULL,
    [Description]                   NVARCHAR (1000) NULL,
    [ProductTypeId]                 INT             NOT NULL,
    [AccountId]                     BIGINT          NOT NULL,
    [ProductStatusId]               INT             NOT NULL,
    [TaxExempt]                     BIT             CONSTRAINT [DF_Product_Taxable] DEFAULT ((0)) NOT NULL,
    [AvailableForPurchase]          BIT             NOT NULL,
    [Quantity]                      DECIMAL (18, 6) NULL,
    [OrderToCashCycleId]            BIGINT          NULL,
    [IsTrackingItems]               BIT             NOT NULL,
    [AvalaraItemCode]               NVARCHAR (50)   NULL,
    [AvalaraTaxCode]                NVARCHAR (25)   NULL,
    [GLCodeId]                      BIGINT          NULL,
    [Deletable]                     BIT             DEFAULT ((1)) NOT NULL,
    [SalesforceId]                  VARCHAR (100)   NULL,
    [NetsuiteItemId]                VARCHAR (100)   NULL,
    [NetsuiteItemRecordType]        TINYINT         NULL,
    [DigitalRiverCountryOfOriginId] BIGINT          NULL,
    [DigitalRiverECCNId]            BIGINT          NULL,
    [DigitalRiverTaxCodeId]         BIGINT          NULL,
    [PushedToDigitalRiver]          BIT             CONSTRAINT [df_PushedToDigitalRiver] DEFAULT ((0)) NULL,
    [QuickBooksItemId]              BIGINT          NULL,
    [QuickBooksRecordType]          VARCHAR (50)    NULL,
    [AnrokProductId]                VARCHAR (255)   NULL,
    CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Product_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_Product_DigitalRiverCountryOfOriginId] FOREIGN KEY ([DigitalRiverCountryOfOriginId]) REFERENCES [Lookup].[Country] ([Id]),
    CONSTRAINT [FK_Product_DigitalRiverECCNId] FOREIGN KEY ([DigitalRiverECCNId]) REFERENCES [dbo].[AccountDigitalRiverECCN] ([Id]),
    CONSTRAINT [FK_Product_DigitalRiverTaxCodeId] FOREIGN KEY ([DigitalRiverTaxCodeId]) REFERENCES [dbo].[AccountDigitalRiverTaxCode] ([Id]),
    CONSTRAINT [FK_Product_GLCode] FOREIGN KEY ([GLCodeId]) REFERENCES [dbo].[GLCode] ([Id]),
    CONSTRAINT [FK_Product_NetsuiteItemRecordType] FOREIGN KEY ([NetsuiteItemRecordType]) REFERENCES [Lookup].[NetsuiteRecordType] ([Id]),
    CONSTRAINT [FK_Product_OrderToCashCycle] FOREIGN KEY ([OrderToCashCycleId]) REFERENCES [dbo].[OrderToCashCycle] ([Id]),
    CONSTRAINT [FK_Product_ProductType] FOREIGN KEY ([ProductStatusId]) REFERENCES [Lookup].[ProductStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_Product_AccountId_AvailableForPurchase]
    ON [dbo].[Product]([AccountId] ASC, [AvailableForPurchase] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Product_ProductStatusId]
    ON [dbo].[Product]([ProductStatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Product_AccountId_ProductTypeId]
    ON [dbo].[Product]([AccountId] ASC, [ProductTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_Product_OrderToCashCycleId]
    ON [dbo].[Product]([OrderToCashCycleId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Product_GLCodeId]
    ON [dbo].[Product]([GLCodeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

