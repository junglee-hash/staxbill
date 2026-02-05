CREATE TABLE [dbo].[Purchase] (
    [Id]                      BIGINT          IDENTITY (1, 1) NOT NULL,
    [ProductId]               BIGINT          NOT NULL,
    [StatusId]                INT             NOT NULL,
    [CustomerId]              BIGINT          NOT NULL,
    [Quantity]                DECIMAL (18, 6) NOT NULL,
    [Name]                    NVARCHAR (2000) NULL,
    [Description]             NVARCHAR (2000) NULL,
    [CreatedTimestamp]        DATETIME        NOT NULL,
    [ModifiedTimestamp]       DATETIME        NOT NULL,
    [EffectiveTimestamp]      DATETIME        NOT NULL,
    [PurchaseTimestamp]       DATETIME        NULL,
    [PricingModelTypeId]      INT             NOT NULL,
    [Amount]                  DECIMAL (18, 6) NOT NULL,
    [TaxableAmount]           DECIMAL (18, 6) NOT NULL,
    [IsEarnedImmediately]     BIT             NOT NULL,
    [EarningInterval]         INT             NULL,
    [EarningNumberOfInterval] INT             NULL,
    [IsTrackingItems]         BIT             NOT NULL,
    [EarningTimingTypeId]     INT             NOT NULL,
    [EarningTimingIntervalId] INT             NOT NULL,
    [SalesforceId]            NVARCHAR (255)  NULL,
    [CancellationTimestamp]   DATETIME        NULL,
    [NetsuiteLocationId]      VARCHAR (100)   NULL,
    [TargetOrderQuantity]     DECIMAL (18, 6) NULL,
    [NetsuiteClassId]         VARCHAR (100)   NULL,
    [NetsuiteBinId]           VARCHAR (100)   NULL,
    [InvoiceOwnerId]          BIGINT          NOT NULL,
    [IsDeleted]               BIT             CONSTRAINT [DF_Purchase_IsDeleted] DEFAULT ('FALSE') NOT NULL,
    [HubSpotDealId]           BIGINT          CONSTRAINT [DF_HubSpotDealId] DEFAULT (NULL) NULL,
    [PricingFormulaTypeId]    INT             CONSTRAINT [DF_PricingFormulaTypeIdPurchase] DEFAULT (NULL) NULL,
    [QuickBooksClassId]       VARCHAR (50)    NULL,
    CONSTRAINT [PK_Purchase] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([PricingFormulaTypeId]) REFERENCES [Lookup].[PricingFormulaType] ([Id]),
    CONSTRAINT [FK_Purchase_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_Purchase_InvoiceOwner] FOREIGN KEY ([InvoiceOwnerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_Purchase_PricingModelType] FOREIGN KEY ([PricingModelTypeId]) REFERENCES [Lookup].[PricingModelType] ([Id]),
    CONSTRAINT [FK_Purchase_Product] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([Id]),
    CONSTRAINT [FK_Purchase_PurchaseStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[PurchaseStatus] ([Id]),
    CONSTRAINT [FK_PurchaseEarningTimingIntervalId_EarningTimingInterval] FOREIGN KEY ([EarningTimingIntervalId]) REFERENCES [Lookup].[EarningTimingInterval] ([Id]),
    CONSTRAINT [FK_PurchaseEarningTimingTypeId_EarningTimingType] FOREIGN KEY ([EarningTimingTypeId]) REFERENCES [Lookup].[EarningTimingType] ([Id]),
    CONSTRAINT [FK_PurchaseIntervalId_Interval] FOREIGN KEY ([EarningInterval]) REFERENCES [Lookup].[Interval] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_Purchase_CustomerId_StatusId]
    ON [dbo].[Purchase]([CustomerId] ASC, [StatusId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Purchase_IsDeleted]
    ON [dbo].[Purchase]([IsDeleted] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Purchase_ProductId_StatusId_CustomerId]
    ON [dbo].[Purchase]([ProductId] ASC, [StatusId] ASC, [CustomerId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_Purchase_StatusId]
    ON [dbo].[Purchase]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

