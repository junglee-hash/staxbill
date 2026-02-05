CREATE TABLE [dbo].[PaymentMethodSharing] (
    [Id]                BIGINT   IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]  DATETIME NOT NULL,
    [ModifiedTimestamp] DATETIME NOT NULL,
    [CustomerId]        BIGINT   NOT NULL,
    [PaymentMethodId]   BIGINT   NOT NULL,
    [Sharing]           BIT      NOT NULL,
    CONSTRAINT [PK_PaymentMethodSharing] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PaymentMethodSharing_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_PaymentMethodSharing_PaymentMethod] FOREIGN KEY ([PaymentMethodId]) REFERENCES [dbo].[PaymentMethod] ([Id])
);


GO

