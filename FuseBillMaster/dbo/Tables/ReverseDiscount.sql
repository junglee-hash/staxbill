CREATE TABLE [dbo].[ReverseDiscount] (
    [Id]                 BIGINT        NOT NULL,
    [Reference]          VARCHAR (500) NULL,
    [OriginalDiscountId] BIGINT        NOT NULL,
    [CreditNoteId]       BIGINT        NOT NULL,
    [ReverseChargeId]    BIGINT        NOT NULL,
    CONSTRAINT [PK_ReverseDiscount] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ReverseDiscount_CreditNote] FOREIGN KEY ([CreditNoteId]) REFERENCES [dbo].[CreditNote] ([Id]),
    CONSTRAINT [FK_ReverseDiscount_Discount] FOREIGN KEY ([OriginalDiscountId]) REFERENCES [dbo].[Discount] ([Id]),
    CONSTRAINT [fk_ReverseDiscount_ReverseChargeId] FOREIGN KEY ([ReverseChargeId]) REFERENCES [dbo].[ReverseCharge] ([Id]),
    CONSTRAINT [FK_ReverseDiscount_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_ReverseDiscount_OriginalDiscountId]
    ON [dbo].[ReverseDiscount]([OriginalDiscountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_ReverseDiscount_ReverseChargeId]
    ON [dbo].[ReverseDiscount]([ReverseChargeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_ReverseDiscount_CreditNoteId]
    ON [dbo].[ReverseDiscount]([CreditNoteId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

