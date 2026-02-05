CREATE TABLE [dbo].[CreditCard] (
    [Id]               BIGINT       NOT NULL,
    [MaskedCardNumber] VARCHAR (20) NOT NULL,
    [ExpirationMonth]  INT          NOT NULL,
    [ExpirationYear]   INT          NOT NULL,
    [IsDebit]          BIT          CONSTRAINT [DF_IsDebit] DEFAULT (NULL) NULL,
    [IsGooglePay]      BIT          CONSTRAINT [DF_IsGooglePay] DEFAULT ((0)) NOT NULL,
    [FirstSix]         VARCHAR (6)  NULL,
    CONSTRAINT [PK_CreditCard] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CreditCard_PaymentMethod] FOREIGN KEY ([Id]) REFERENCES [dbo].[PaymentMethod] ([Id])
);


GO

