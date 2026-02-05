CREATE TABLE [dbo].[SubscriptionCustomField] (
    [Id]                BIGINT          IDENTITY (1, 1) NOT NULL,
    [CustomFieldId]     BIGINT          NOT NULL,
    [SubscriptionId]    BIGINT          NOT NULL,
    [StringValue]       NVARCHAR (1000) NULL,
    [DateValue]         DATETIME        NULL,
    [NumericValue]      DECIMAL (18, 6) NULL,
    [CreatedTimestamp]  DATETIME        NOT NULL,
    [ModifiedTimestamp] DATETIME        NOT NULL,
    CONSTRAINT [PK_SubscriptionCustomField] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SubscriptionCustomField_CustomField] FOREIGN KEY ([CustomFieldId]) REFERENCES [dbo].[CustomField] ([Id]),
    CONSTRAINT [FK_SubscriptionCustomField_Subscription] FOREIGN KEY ([SubscriptionId]) REFERENCES [dbo].[Subscription] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_SubscriptionCustomField_SubscriptionId]
    ON [dbo].[SubscriptionCustomField]([SubscriptionId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_SubscriptionCustomField_CustomFieldId]
    ON [dbo].[SubscriptionCustomField]([CustomFieldId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

