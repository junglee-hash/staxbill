CREATE TABLE [dbo].[CustomerPaymentValidationLock] (
    [Id]               BIGINT   NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    [UnlockTimestamp]  DATETIME NULL,
    CONSTRAINT [PK_CustomerPaymentValidationLock] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CustomerPaymentValidationLock_Customer] FOREIGN KEY ([Id]) REFERENCES [dbo].[Customer] ([Id])
);


GO

