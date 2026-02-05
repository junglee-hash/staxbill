CREATE TABLE [dbo].[Address] (
    [Id]                          BIGINT         IDENTITY (1, 1) NOT NULL,
    [ModifiedTimestamp]           DATETIME       NOT NULL,
    [CreatedTimestamp]            DATETIME       NOT NULL,
    [CustomerAddressPreferenceId] BIGINT         NOT NULL,
    [CompanyName]                 NVARCHAR (255) NULL,
    [Line1]                       NVARCHAR (255) NULL,
    [Line2]                       NVARCHAR (255) NULL,
    [CountryId]                   BIGINT         NULL,
    [StateId]                     BIGINT         NULL,
    [City]                        NVARCHAR (50)  NULL,
    [PostalZip]                   NVARCHAR (10)  NULL,
    [AddressTypeId]               INT            NOT NULL,
    [County]                      NVARCHAR (150) NULL,
    [Validated]                   BIT            DEFAULT ((0)) NOT NULL,
    [Country]                     NVARCHAR (250) NULL,
    [State]                       NVARCHAR (250) NULL,
    [Invalid]                     BIT            CONSTRAINT [DF_Invalid] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Address] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Address_AddressType] FOREIGN KEY ([AddressTypeId]) REFERENCES [Lookup].[AddressType] ([Id]),
    CONSTRAINT [FK_Address_Country] FOREIGN KEY ([CountryId]) REFERENCES [Lookup].[Country] ([Id]),
    CONSTRAINT [FK_Address_CustomerAddressPreference] FOREIGN KEY ([CustomerAddressPreferenceId]) REFERENCES [dbo].[CustomerAddressPreference] ([Id]),
    CONSTRAINT [FK_Address_State] FOREIGN KEY ([StateId]) REFERENCES [Lookup].[State] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_Address_CountryId]
    ON [dbo].[Address]([CountryId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Address_CustomerAddressPreferenceId]
    ON [dbo].[Address]([CustomerAddressPreferenceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Address_StateId]
    ON [dbo].[Address]([StateId] ASC)
    INCLUDE([Id], [ModifiedTimestamp], [CreatedTimestamp], [CustomerAddressPreferenceId], [CompanyName], [Line1], [Line2], [CountryId], [City], [PostalZip], [AddressTypeId]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Address_AddressTypeId]
    ON [dbo].[Address]([AddressTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

