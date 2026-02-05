CREATE TABLE [dbo].[DraftCharge] (
    [Id]                      BIGINT          IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]        DATETIME        NOT NULL,
    [ModifiedTimestamp]       DATETIME        NOT NULL,
    [Quantity]                DECIMAL (18, 6) NOT NULL,
    [UnitPrice]               DECIMAL (18, 6) NOT NULL,
    [Amount]                  MONEY           NOT NULL,
    [DraftInvoiceId]          BIGINT          NULL,
    [Name]                    NVARCHAR (2000) NULL,
    [Description]             NVARCHAR (2000) NULL,
    [TransactionTypeId]       INT             NOT NULL,
    [CurrencyId]              BIGINT          NOT NULL,
    [EffectiveTimestamp]      DATETIME        NULL,
    [ProratedUnitPrice]       DECIMAL (18, 6) NULL,
    [RangeQuantity]           DECIMAL (18, 6) NULL,
    [TaxableAmount]           DECIMAL (18, 6) NOT NULL,
    [StatusId]                INT             NOT NULL,
    [SortOrder]               TINYINT         NOT NULL,
    [CustomerId]              BIGINT          NOT NULL,
    [EarningTimingTypeId]     INT             NOT NULL,
    [EarningTimingIntervalId] INT             NOT NULL,
    [ProductId]               BIGINT          NULL,
    [DigitalRiverCheckoutId]  VARCHAR (50)    NULL,
    CONSTRAINT [PK_DraftCharge] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DraftCharge_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_DraftCharge_DraftChargeStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[DraftChargeStatus] ([Id]),
    CONSTRAINT [FK_DraftCharge_DraftInvoice] FOREIGN KEY ([DraftInvoiceId]) REFERENCES [dbo].[DraftInvoice] ([Id]),
    CONSTRAINT [FK_DraftCharge_Product] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([Id]),
    CONSTRAINT [FK_DraftCharge_TransactionType] FOREIGN KEY ([TransactionTypeId]) REFERENCES [Lookup].[TransactionType] ([Id]),
    CONSTRAINT [FK_DraftChargeCurrencyId_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id]),
    CONSTRAINT [FK_DraftChargeEarningTimingIntervalId_EarningTimingInterval] FOREIGN KEY ([EarningTimingIntervalId]) REFERENCES [Lookup].[EarningTimingInterval] ([Id]),
    CONSTRAINT [FK_DraftChargeEarningTimingTypeId_EarningTimingType] FOREIGN KEY ([EarningTimingTypeId]) REFERENCES [Lookup].[EarningTimingType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_DraftCharge_ProductId]
    ON [dbo].[DraftCharge]([ProductId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_DraftCharge_DraftInvoiceId]
    ON [dbo].[DraftCharge]([DraftInvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_DraftCharge_StatusId]
    ON [dbo].[DraftCharge]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_DraftCharge_CustomerId_EffectiveTimestamp_INCL]
    ON [dbo].[DraftCharge]([CustomerId] ASC, [EffectiveTimestamp] ASC)
    INCLUDE([Amount], [DraftInvoiceId], [StatusId]) WITH (FILLFACTOR = 100);


GO

