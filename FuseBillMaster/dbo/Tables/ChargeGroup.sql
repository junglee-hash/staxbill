CREATE TABLE [dbo].[ChargeGroup] (
    [Id]             BIGINT          IDENTITY (1, 1) NOT NULL,
    [Name]           NVARCHAR (100)  NOT NULL,
    [Description]    NVARCHAR (1000) NULL,
    [Reference]      NVARCHAR (255)  NULL,
    [InvoiceId]      BIGINT          NOT NULL,
    [SubscriptionId] BIGINT          NULL,
    CONSTRAINT [PK_ChargeGroup] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ChargeGroup_InvoiceId] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id]),
    CONSTRAINT [FK_ChargeGroup_SubscriptionId] FOREIGN KEY ([SubscriptionId]) REFERENCES [dbo].[Subscription] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_ChargeGroup_InvoiceId]
    ON [dbo].[ChargeGroup]([InvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

