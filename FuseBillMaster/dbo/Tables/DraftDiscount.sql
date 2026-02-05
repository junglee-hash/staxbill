CREATE TABLE [dbo].[DraftDiscount] (
    [Id]                       BIGINT          IDENTITY (1, 1) NOT NULL,
    [ConfiguredDiscountAmount] DECIMAL (18, 6) NOT NULL,
    [Amount]                   DECIMAL (18, 6) NOT NULL,
    [DraftChargeId]            BIGINT          NOT NULL,
    [DiscountTypeId]           INT             NOT NULL,
    [CreatedTimestamp]         DATETIME        NOT NULL,
    [EffectiveTimestamp]       DATETIME        NULL,
    [TransactionTypeId]        INT             CONSTRAINT [DF_DraftDiscount_TransactionTypeId] DEFAULT ((14)) NOT NULL,
    [Description]              NVARCHAR (2000) NULL,
    [CurrencyId]               BIGINT          NOT NULL,
    [Quantity]                 DECIMAL (18, 6) NOT NULL,
    [NetsuiteItemId]           VARCHAR (100)   NULL,
    [CouponId]                 BIGINT          NULL,
    CONSTRAINT [PK_DraftDiscount] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_DraftDiscount_DiscountType] FOREIGN KEY ([DiscountTypeId]) REFERENCES [Lookup].[DiscountType] ([Id]),
    CONSTRAINT [FK_DraftDiscount_DraftCharge] FOREIGN KEY ([DraftChargeId]) REFERENCES [dbo].[DraftCharge] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_DraftDiscount_DraftChargeId]
    ON [dbo].[DraftDiscount]([DraftChargeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

