CREATE TABLE [dbo].[ExternalPaymentMethod] (
    [Id]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [PaymentMethodId]    BIGINT          NOT NULL,
    [Token]              NVARCHAR (1000) NOT NULL,
    [ExternalCustomerId] NVARCHAR (1000) NULL,
    [ExternalCardId]     NVARCHAR (1000) NOT NULL,
    [ProcessorId]        INT             NULL,
    [GatewayId]          BIGINT          NULL,
    [AccountId]          BIGINT          NOT NULL,
    [CreatedTimestamp]   DATETIME        DEFAULT (getutcdate()) NOT NULL,
    [ModifiedTimestamp]  DATETIME        NOT NULL,
    [EffectiveTimestamp] DATETIME        NOT NULL,
    CONSTRAINT [PK_ExternalPaymentMethod] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PaymentMethod_Id] FOREIGN KEY ([PaymentMethodId]) REFERENCES [dbo].[PaymentMethod] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_ExternalPaymentMethod_AccountId_PaymentMethodId]
    ON [dbo].[ExternalPaymentMethod]([AccountId] ASC, [PaymentMethodId] ASC)
    INCLUDE([Id]);


GO

