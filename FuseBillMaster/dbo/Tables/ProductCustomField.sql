CREATE TABLE [dbo].[ProductCustomField] (
    [Id]                  BIGINT          IDENTITY (1, 1) NOT NULL,
    [ProductId]           BIGINT          NOT NULL,
    [CustomFieldId]       BIGINT          NOT NULL,
    [DefaultStringValue]  NVARCHAR (1000) NULL,
    [DefaultDateValue]    DATETIME        NULL,
    [DefaultNumericValue] DECIMAL (18, 6) NULL,
    [CreatedTimestamp]    DATETIME        NOT NULL,
    [ModifiedTimestamp]   DATETIME        NOT NULL,
    CONSTRAINT [PK_ProductCustomField] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ProductCustomField_CustomField] FOREIGN KEY ([CustomFieldId]) REFERENCES [dbo].[CustomField] ([Id]),
    CONSTRAINT [fk_ProductCustomField_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [dbo].[Product] ([Id]),
    CONSTRAINT [UK_ProductIdCustomFieldId] UNIQUE NONCLUSTERED ([ProductId] ASC, [CustomFieldId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [FKIX_ProductCustomField_ProductId]
    ON [dbo].[ProductCustomField]([ProductId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_ProductCustomField_CustomFieldId]
    ON [dbo].[ProductCustomField]([CustomFieldId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

