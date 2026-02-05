CREATE TABLE [dbo].[CreditCardExpiryActivity] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [MonthNotice]      INT      NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    [CreditCardId]     BIGINT   NOT NULL,
    CONSTRAINT [pk_CreditCardExpiryActivity] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CreditCardExpiryActivity_CreditCard] FOREIGN KEY ([CreditCardId]) REFERENCES [dbo].[CreditCard] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CreditCardExpiryActivity_CreditCardId]
    ON [dbo].[CreditCardExpiryActivity]([CreditCardId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

