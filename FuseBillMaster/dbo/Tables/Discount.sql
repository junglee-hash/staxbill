CREATE TABLE [dbo].[Discount] (
    [Id]                       BIGINT          NOT NULL,
    [ChargeId]                 BIGINT          NOT NULL,
    [ConfiguredDiscountAmount] DECIMAL (18, 6) NOT NULL,
    [DiscountTypeId]           INT             NOT NULL,
    [RemainingReversalAmount]  DECIMAL (18, 6) NOT NULL,
    [UnearnedAmount]           DECIMAL (18, 6) NOT NULL,
    [Quantity]                 DECIMAL (18, 6) NOT NULL,
    [NetsuiteDiscountItemId]   VARCHAR (100)   NULL,
    [CouponId]                 BIGINT          NULL,
    CONSTRAINT [PK_Discount] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Discount_Charge] FOREIGN KEY ([ChargeId]) REFERENCES [dbo].[Charge] ([Id]),
    CONSTRAINT [FK_Discount_DiscountType] FOREIGN KEY ([DiscountTypeId]) REFERENCES [Lookup].[DiscountType] ([Id]),
    CONSTRAINT [FK_Discount_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_Discount_ChargeId]
    ON [dbo].[Discount]([ChargeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_Discount_DiscountTypeId]
    ON [dbo].[Discount]([DiscountTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

