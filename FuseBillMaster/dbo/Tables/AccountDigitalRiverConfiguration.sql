CREATE TABLE [dbo].[AccountDigitalRiverConfiguration] (
    [Id]                       BIGINT       NOT NULL,
    [PublicKey]                VARCHAR (50) NULL,
    [ConfidentialKey]          VARCHAR (50) NULL,
    [CountryOfOriginDefaultId] BIGINT       CONSTRAINT [df_CountryOfOriginDefaultId] DEFAULT ((840)) NOT NULL,
    CONSTRAINT [PK_AccountDigitalRiverConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountDigitalRiverConfiguration_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountDigitalRiverConfiguration_CountryId] FOREIGN KEY ([CountryOfOriginDefaultId]) REFERENCES [Lookup].[Country] ([Id])
);


GO

