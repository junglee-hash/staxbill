CREATE TABLE [dbo].[PaymentMethodValidationConcurrencyLock] (
    [Id]              BIGINT   NOT NULL,
    [UnlockTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_PaymentMethodValidationConcurrencyLock] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PaymentMethodValidationConcurrencyLock_Customer] FOREIGN KEY ([Id]) REFERENCES [dbo].[Customer] ([Id])
);


GO

