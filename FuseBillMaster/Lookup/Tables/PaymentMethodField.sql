CREATE TABLE [Lookup].[PaymentMethodField] (
    [Id]                             BIGINT       NOT NULL,
    [CustomerInformationFieldTypeId] INT          NOT NULL,
    [Key]                            VARCHAR (50) NOT NULL,
    [Name]                           VARCHAR (50) NOT NULL,
    [MaxLength]                      INT          NOT NULL,
    CONSTRAINT [PK_PaymentMethodField] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PaymentMethodField_CustomerInformationFieldType] FOREIGN KEY ([CustomerInformationFieldTypeId]) REFERENCES [Lookup].[CustomerInformationFieldType] ([Id])
);


GO

