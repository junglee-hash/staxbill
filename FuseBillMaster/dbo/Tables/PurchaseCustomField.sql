CREATE TABLE [dbo].[PurchaseCustomField] (
    [Id]                BIGINT          IDENTITY (1, 1) NOT NULL,
    [CustomFieldId]     BIGINT          NOT NULL,
    [PurchaseId]        BIGINT          NOT NULL,
    [StringValue]       NVARCHAR (1000) NULL,
    [DateValue]         DATETIME        NULL,
    [NumericValue]      DECIMAL (18, 6) NULL,
    [CreatedTimestamp]  DATETIME        NOT NULL,
    [ModifiedTimestamp] DATETIME        NOT NULL,
    CONSTRAINT [PK_PurchaseCustomField] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PurchaseCustomField_CustomField] FOREIGN KEY ([CustomFieldId]) REFERENCES [dbo].[CustomField] ([Id]),
    CONSTRAINT [FK_PurchaseCustomField_Purchase] FOREIGN KEY ([PurchaseId]) REFERENCES [dbo].[Purchase] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_PurchaseCustomField_CustomFieldId]
    ON [dbo].[PurchaseCustomField]([CustomFieldId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_PurchaseCustomField_PurchaseId]
    ON [dbo].[PurchaseCustomField]([PurchaseId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

