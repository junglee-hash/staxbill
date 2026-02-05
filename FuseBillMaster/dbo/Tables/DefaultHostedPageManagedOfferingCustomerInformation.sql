CREATE TABLE [dbo].[DefaultHostedPageManagedOfferingCustomerInformation] (
    [Id]         BIGINT         NOT NULL,
    [FieldValue] NVARCHAR (100) NOT NULL,
    [Visible]    BIT            NOT NULL,
    [Required]   BIT            NOT NULL,
    CONSTRAINT [PK_DefaultHostedPageManagedOfferingCustomerInformation] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DefaultHostedPageManagedOfferingCustomerInformation_CustomerInformationField] FOREIGN KEY ([Id]) REFERENCES [Lookup].[CustomerInformationField] ([Id])
);


GO

