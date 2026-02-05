CREATE TABLE [dbo].[VoidReverseDiscount] (
    [Id]                        BIGINT        NOT NULL,
    [Reference]                 VARCHAR (500) NULL,
    [OriginalReverseDiscountId] BIGINT        NOT NULL,
    [CreditNoteId]              BIGINT        NOT NULL,
    CONSTRAINT [PK_VoidReverseDiscount] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_VoidReverseDiscount_CreditNote] FOREIGN KEY ([CreditNoteId]) REFERENCES [dbo].[CreditNote] ([Id]),
    CONSTRAINT [FK_VoidReverseDiscount_ReverseDiscount] FOREIGN KEY ([OriginalReverseDiscountId]) REFERENCES [dbo].[ReverseDiscount] ([Id]),
    CONSTRAINT [FK_VoidReverseDiscount_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

