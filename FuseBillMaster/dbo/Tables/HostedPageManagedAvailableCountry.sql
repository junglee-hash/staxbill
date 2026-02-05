CREATE TABLE [dbo].[HostedPageManagedAvailableCountry] (
    [Id]                                   BIGINT IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedSelfServicePortalId] BIGINT NOT NULL,
    [CountryId]                            BIGINT NOT NULL,
    [AddressTypeId]                        INT    NULL,
    [SortOrder]                            INT    NOT NULL,
    CONSTRAINT [PK_HostedPageManagedAvailableCountry] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_HostedPageManagedAvailableCountry_AddressType] FOREIGN KEY ([AddressTypeId]) REFERENCES [Lookup].[AddressType] ([Id]),
    CONSTRAINT [FK_HostedPageManagedAvailableCountry_Country] FOREIGN KEY ([CountryId]) REFERENCES [Lookup].[Country] ([Id]),
    CONSTRAINT [FK_HostedPageManagedAvailableCountry_HostedPageManagedSelfServicePortal] FOREIGN KEY ([HostedPageManagedSelfServicePortalId]) REFERENCES [dbo].[HostedPageManagedSelfServicePortal] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_HostedPageManagedAvailableCountry_HostedPageManagedSelfServicePortalId]
    ON [dbo].[HostedPageManagedAvailableCountry]([HostedPageManagedSelfServicePortalId] ASC);


GO

