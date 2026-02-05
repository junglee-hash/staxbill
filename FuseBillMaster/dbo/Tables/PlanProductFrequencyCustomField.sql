CREATE TABLE [dbo].[PlanProductFrequencyCustomField] (
    [Id]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [PlanProductUniqueId]   BIGINT          NOT NULL,
    [PlanFrequencyUniqueId] BIGINT          NOT NULL,
    [CustomFieldId]         BIGINT          NOT NULL,
    [DefaultStringValue]    NVARCHAR (1000) NULL,
    [DefaultDateValue]      DATETIME        NULL,
    [DefaultNumericValue]   DECIMAL (18, 6) NULL,
    [CreatedTimestamp]      DATETIME        NOT NULL,
    [ModifiedTimestamp]     DATETIME        NOT NULL,
    CONSTRAINT [PK_PlanProductFrequencyCustomField] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PlanProductFrequencyCustomField_CustomField] FOREIGN KEY ([CustomFieldId]) REFERENCES [dbo].[CustomField] ([Id]),
    CONSTRAINT [FK_PlanProductFrequencyCustomField_PlanFrequencyKey] FOREIGN KEY ([PlanFrequencyUniqueId]) REFERENCES [dbo].[PlanFrequencyKey] ([Id]),
    CONSTRAINT [FK_PlanProductFrequencyCustomField_PlanProductKey] FOREIGN KEY ([PlanProductUniqueId]) REFERENCES [dbo].[PlanProductKey] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_PlanProductFrequencyCustomField_PlanProductUniqueId]
    ON [dbo].[PlanProductFrequencyCustomField]([PlanProductUniqueId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_PlanProductFrequencyCustomField_CustomFieldId]
    ON [dbo].[PlanProductFrequencyCustomField]([CustomFieldId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_PlanProductFrequencyCustomField_PlanFrequencyUniqueId]
    ON [dbo].[PlanProductFrequencyCustomField]([PlanFrequencyUniqueId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

