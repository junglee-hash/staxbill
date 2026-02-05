CREATE TABLE [dbo].[PlanFrequencyCustomField] (
    [Id]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [CustomFieldId]         BIGINT          NOT NULL,
    [DefaultStringValue]    NVARCHAR (1000) NULL,
    [DefaultDateValue]      DATETIME        NULL,
    [DefaultNumericValue]   DECIMAL (18, 6) NULL,
    [CreatedTimestamp]      DATETIME        NOT NULL,
    [ModifiedTimestamp]     DATETIME        NOT NULL,
    [PlanFrequencyUniqueId] BIGINT          NOT NULL,
    CONSTRAINT [PK_PlanFrequencyCustomField] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PlanFrequencyCustomField_CustomField] FOREIGN KEY ([CustomFieldId]) REFERENCES [dbo].[CustomField] ([Id]),
    CONSTRAINT [fk_PlanFrequencyCustomField_PlanFrequencyUniqueId] FOREIGN KEY ([PlanFrequencyUniqueId]) REFERENCES [dbo].[PlanFrequencyKey] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_PlanFrequencyCustomField_CustomFieldId]
    ON [dbo].[PlanFrequencyCustomField]([CustomFieldId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_PlanFrequencyCustomField_PlanFrequencyUniqueId]
    ON [dbo].[PlanFrequencyCustomField]([PlanFrequencyUniqueId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

