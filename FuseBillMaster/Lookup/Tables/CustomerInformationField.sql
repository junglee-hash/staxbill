CREATE TABLE [Lookup].[CustomerInformationField] (
    [Id]                             BIGINT       NOT NULL,
    [CustomerInformationFieldTypeId] INT          NOT NULL,
    [Key]                            VARCHAR (50) NOT NULL,
    [Name]                           VARCHAR (50) NOT NULL,
    [MaxLength]                      INT          NOT NULL,
    CONSTRAINT [PK_CustomerInformationField] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CustomerInformationField_CustomerInformationFieldType] FOREIGN KEY ([CustomerInformationFieldTypeId]) REFERENCES [Lookup].[CustomerInformationFieldType] ([Id])
);


GO

