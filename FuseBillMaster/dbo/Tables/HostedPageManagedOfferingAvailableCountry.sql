CREATE TABLE [dbo].[HostedPageManagedOfferingAvailableCountry] (
    [Id]                          BIGINT IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedOfferingId] BIGINT NOT NULL,
    [CountryId]                   BIGINT NOT NULL,
    [AddressTypeId]               INT    NOT NULL,
    [SortOrder]                   INT    NOT NULL,
    CONSTRAINT [PK_HostedPageManagedOfferingAvailableCountry] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedOfferingAvailableCountry_AddressType] FOREIGN KEY ([AddressTypeId]) REFERENCES [Lookup].[AddressType] ([Id]),
    CONSTRAINT [FK_HostedPageManagedOfferingAvailableCountry_Country] FOREIGN KEY ([CountryId]) REFERENCES [Lookup].[Country] ([Id]),
    CONSTRAINT [FK_HostedPageManagedOfferingAvailableCountry_HostedPageManagedOffering] FOREIGN KEY ([HostedPageManagedOfferingId]) REFERENCES [dbo].[HostedPageManagedOffering] ([Id])
);


GO

