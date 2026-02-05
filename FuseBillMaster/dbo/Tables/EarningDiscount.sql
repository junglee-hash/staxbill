CREATE TABLE [dbo].[EarningDiscount] (
    [Id]         BIGINT         NOT NULL,
    [DiscountId] BIGINT         NOT NULL,
    [Reference]  NVARCHAR (500) NULL,
    CONSTRAINT [PK_EarningDiscount] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EarningDiscount_Discount] FOREIGN KEY ([DiscountId]) REFERENCES [dbo].[Discount] ([Id]),
    CONSTRAINT [FK_EarningDiscount_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_EarningDiscount_DiscountId]
    ON [dbo].[EarningDiscount]([DiscountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

