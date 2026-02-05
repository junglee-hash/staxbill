CREATE TABLE [dbo].[InvoiceAddressAdditional] (
    [Id]                          BIGINT         IDENTITY (1, 1) NOT NULL,
    [InvoiceCustomerAdditionalId] BIGINT         NOT NULL,
    [ModifiedTimestamp]           DATETIME       NOT NULL,
    [CreatedTimestamp]            DATETIME       NOT NULL,
    [CompanyName]                 NVARCHAR (255) NULL,
    [Line1]                       NVARCHAR (255) NULL,
    [Line2]                       NVARCHAR (255) NULL,
    [CountryId]                   BIGINT         NULL,
    [StateId]                     BIGINT         NULL,
    [City]                        NVARCHAR (50)  NULL,
    [PostalZip]                   NVARCHAR (10)  NULL,
    [AddressTypeId]               INT            NOT NULL,
    [CountryName]                 NVARCHAR (250) CONSTRAINT [DF_InvoiceAddressAdditional_Country] DEFAULT ('') NULL,
    [StateName]                   NVARCHAR (250) NULL,
    [UsedForAvalara]              BIT            NULL,
    CONSTRAINT [PK_InvoiceAddressAdditional] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_InvoiceAddressAdditional_AddressTypeId] FOREIGN KEY ([AddressTypeId]) REFERENCES [Lookup].[AddressType] ([Id]),
    CONSTRAINT [FK_InvoiceAddressAdditional_CountryId] FOREIGN KEY ([CountryId]) REFERENCES [Lookup].[Country] ([Id]),
    CONSTRAINT [FK_InvoiceAddressAdditional_InvoiceCustomerAdditionalId] FOREIGN KEY ([InvoiceCustomerAdditionalId]) REFERENCES [dbo].[InvoiceCustomerAdditional] ([Id]),
    CONSTRAINT [FK_InvoiceAddressAdditional_StateId] FOREIGN KEY ([StateId]) REFERENCES [Lookup].[State] ([Id])
);


GO

