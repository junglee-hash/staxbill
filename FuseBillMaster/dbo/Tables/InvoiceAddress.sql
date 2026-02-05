CREATE TABLE [dbo].[InvoiceAddress] (
    [Id]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [ModifiedTimestamp] DATETIME       NOT NULL,
    [CreatedTimestamp]  DATETIME       NOT NULL,
    [InvoiceId]         BIGINT         NOT NULL,
    [CompanyName]       NVARCHAR (255) NULL,
    [Line1]             NVARCHAR (255) NULL,
    [Line2]             NVARCHAR (255) NULL,
    [CountryId]         BIGINT         NULL,
    [StateId]           BIGINT         NULL,
    [City]              NVARCHAR (50)  NULL,
    [PostalZip]         NVARCHAR (10)  NULL,
    [AddressTypeId]     INT            NOT NULL,
    [CountryName]       NVARCHAR (250) CONSTRAINT [DF_InvoiceAddress_Country] DEFAULT ('') NULL,
    [StateName]         NVARCHAR (250) CONSTRAINT [DF_InvoiceAddress_State] DEFAULT ('') NULL,
    [UsedForAvalara]    BIT            NULL,
    CONSTRAINT [PK_InvoiceAddress] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_InvoiceAddress_AddressTypeId] FOREIGN KEY ([AddressTypeId]) REFERENCES [Lookup].[AddressType] ([Id]),
    CONSTRAINT [FK_InvoiceAddress_CountryId] FOREIGN KEY ([CountryId]) REFERENCES [Lookup].[Country] ([Id]),
    CONSTRAINT [FK_InvoiceAddress_InvoiceId] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id]),
    CONSTRAINT [FK_InvoiceAddress_StateId] FOREIGN KEY ([StateId]) REFERENCES [Lookup].[State] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_InvoiceAddress_InvoiceId]
    ON [dbo].[InvoiceAddress]([InvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

