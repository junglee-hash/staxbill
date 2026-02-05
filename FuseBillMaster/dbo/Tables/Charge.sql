CREATE TABLE [dbo].[Charge] (
    [Id]                               BIGINT           NOT NULL,
    [InvoiceId]                        BIGINT           NULL,
    [DraftChargeId]                    BIGINT           NOT NULL,
    [UnitPrice]                        DECIMAL (18, 6)  NOT NULL,
    [Quantity]                         DECIMAL (18, 6)  NOT NULL,
    [EarningStartDate]                 DATETIME         NOT NULL,
    [EarningEndDate]                   DATETIME         NOT NULL,
    [Name]                             NVARCHAR (2000)  NULL,
    [ProratedUnitPrice]                DECIMAL (18, 6)  NULL,
    [RangeQuantity]                    DECIMAL (18, 6)  NULL,
    [RemainingReverseAmount]           DECIMAL (18, 6)  NOT NULL,
    [ChargeGroupId]                    BIGINT           NOT NULL,
    [EarningTimingTypeId]              INT              NOT NULL,
    [EarningTimingIntervalId]          INT              NOT NULL,
    [GLCodeId]                         BIGINT           NULL,
    [SalesTrackingCode1Id]             BIGINT           NULL,
    [SalesTrackingCode2Id]             BIGINT           NULL,
    [SalesTrackingCode3Id]             BIGINT           NULL,
    [SalesTrackingCode4Id]             BIGINT           NULL,
    [SalesTrackingCode5Id]             BIGINT           NULL,
    [NetsuiteChargeItem]               VARCHAR (100)    NULL,
    [NetsuiteChargeItemRecordType]     TINYINT          NULL,
    [DigitalRiverCheckoutId]           VARCHAR (50)     NULL,
    [DigitalRiverItemReconciliationId] VARCHAR (50)     NULL,
    [QuickBooksItemId]                 BIGINT           NULL,
    [QuickBooksRecordType]             VARCHAR (50)     NULL,
    [QuickBooksClassId]                VARCHAR (50)     NULL,
    [AnrokProductId]                   VARCHAR (255)    NULL,
    [AnrokLineItemId]                  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_Charge] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Charge_ChargeGroupId] FOREIGN KEY ([ChargeGroupId]) REFERENCES [dbo].[ChargeGroup] ([Id]),
    CONSTRAINT [FK_Charge_GLCode] FOREIGN KEY ([GLCodeId]) REFERENCES [dbo].[GLCode] ([Id]),
    CONSTRAINT [FK_Charge_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id]),
    CONSTRAINT [FK_Charge_NetsuiteChargeItemRecordType] FOREIGN KEY ([NetsuiteChargeItemRecordType]) REFERENCES [Lookup].[NetsuiteRecordType] ([Id]),
    CONSTRAINT [FK_Charge_SalesTrackingCode1] FOREIGN KEY ([SalesTrackingCode1Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Charge_SalesTrackingCode2] FOREIGN KEY ([SalesTrackingCode2Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Charge_SalesTrackingCode3] FOREIGN KEY ([SalesTrackingCode3Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Charge_SalesTrackingCode4] FOREIGN KEY ([SalesTrackingCode4Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Charge_SalesTrackingCode5] FOREIGN KEY ([SalesTrackingCode5Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Charge_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id]),
    CONSTRAINT [FK_ChargeEarningTimingIntervalId_EarningTimingInterval] FOREIGN KEY ([EarningTimingIntervalId]) REFERENCES [Lookup].[EarningTimingInterval] ([Id]),
    CONSTRAINT [FK_ChargeEarningTimingTypeId_EarningTimingType] FOREIGN KEY ([EarningTimingTypeId]) REFERENCES [Lookup].[EarningTimingType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_Charge_GLCodeId]
    ON [dbo].[Charge]([GLCodeId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Charge_ChargeGroupId]
    ON [dbo].[Charge]([ChargeGroupId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Charge_InvoiceId]
    ON [dbo].[Charge]([InvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Charge_EarningTimingTypeId_EarningTimingIntervalId]
    ON [dbo].[Charge]([EarningTimingTypeId] ASC, [EarningTimingIntervalId] ASC)
    INCLUDE([Id], [EarningStartDate], [EarningEndDate], [InvoiceId]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_Charge_EarningTimingIntervalId]
    ON [dbo].[Charge]([EarningTimingIntervalId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

