CREATE TABLE [dbo].[HostedPageManagedOfferingCustomerInformation] (
    [Id]                          BIGINT         IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedOfferingId] BIGINT         NOT NULL,
    [CustomerInformationFieldId]  BIGINT         NOT NULL,
    [Label]                       NVARCHAR (100) NOT NULL,
    [Visible]                     BIT            NOT NULL,
    [Required]                    BIT            NOT NULL,
    [DefaultValue]                NVARCHAR (255) NULL,
    CONSTRAINT [PK_HostedPageManagedOfferingCustomerInformation] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedOfferingCustomerInformation_CustomerInformationField] FOREIGN KEY ([CustomerInformationFieldId]) REFERENCES [Lookup].[CustomerInformationField] ([Id]),
    CONSTRAINT [FK_HostedPageManagedOfferingCustomerInformation_HostedPageManagedOffering] FOREIGN KEY ([HostedPageManagedOfferingId]) REFERENCES [dbo].[HostedPageManagedOffering] ([Id])
);


GO

