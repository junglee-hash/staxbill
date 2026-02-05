CREATE TABLE [dbo].[CustomField] (
    [Id]                BIGINT        IDENTITY (1, 1) NOT NULL,
    [AccountId]         BIGINT        NOT NULL,
    [FriendlyName]      VARCHAR (255) NOT NULL,
    [Key]               VARCHAR (255) NOT NULL,
    [DataTypeId]        INT           NOT NULL,
    [StatusId]          INT           NOT NULL,
    [CreatedTimestamp]  DATETIME      NOT NULL,
    [ModifiedTimestamp] DATETIME      NOT NULL,
    CONSTRAINT [PK_CustomField] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomField_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_CustomField_CustomFieldDataType] FOREIGN KEY ([DataTypeId]) REFERENCES [Lookup].[CustomFieldDataType] ([Id]),
    CONSTRAINT [FK_CustomField_CustomFieldStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[CustomFieldStatus] ([Id]),
    CONSTRAINT [UK_CustomField_Account_Key] UNIQUE NONCLUSTERED ([AccountId] ASC, [Key] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomField_DataTypeId]
    ON [dbo].[CustomField]([DataTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomField_StatusId]
    ON [dbo].[CustomField]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

