CREATE TABLE [dbo].[AchCard] (
    [Id]                  BIGINT       NOT NULL,
    [MaskedAccountNumber] VARCHAR (20) NOT NULL,
    [MaskedTransitNumber] VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_AchCard] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AchCard_PaymentMethod] FOREIGN KEY ([Id]) REFERENCES [dbo].[PaymentMethod] ([Id])
);


GO

