CREATE TABLE [dbo].[SubscriptionProductCustomField] (
    [Id]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [SubscriptionProductId] BIGINT          NOT NULL,
    [CustomFieldId]         BIGINT          NOT NULL,
    [StringValue]           NVARCHAR (1000) NULL,
    [DateValue]             DATETIME        NULL,
    [NumericValue]          DECIMAL (18, 6) NULL,
    [CreatedTimestamp]      DATETIME        NOT NULL,
    [ModifiedTimestamp]     DATETIME        NOT NULL,
    CONSTRAINT [PK_SubscriptionProductCustomField] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SubscriptionProductCustomField_CustomField] FOREIGN KEY ([CustomFieldId]) REFERENCES [dbo].[CustomField] ([Id]),
    CONSTRAINT [FK_SubscriptionProductCustomField_SubscriptionProduct] FOREIGN KEY ([SubscriptionProductId]) REFERENCES [dbo].[SubscriptionProduct] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_SubscriptionProductCustomField_CustomFieldId]
    ON [dbo].[SubscriptionProductCustomField]([CustomFieldId] ASC)
    INCLUDE([SubscriptionProductId], [StringValue]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_SubscriptionProductCustomField_SubscriptionProductId]
    ON [dbo].[SubscriptionProductCustomField]([SubscriptionProductId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

