CREATE TABLE [dbo].[AccountAvalaraNexus] (
    [Id]                        BIGINT        IDENTITY (1, 1) NOT NULL,
    [AccountId]                 BIGINT        NOT NULL,
    [AvalaraId]                 BIGINT        NOT NULL,
    [CompanyId]                 BIGINT        NOT NULL,
    [Country]                   VARCHAR (10)  NOT NULL,
    [Region]                    VARCHAR (10)  NULL,
    [JurisdictionTypeId]        VARCHAR (100) NOT NULL,
    [JurisCode]                 VARCHAR (10)  NULL,
    [JurisName]                 VARCHAR (100) NULL,
    [AvalaraEffectiveDate]      DATETIME      NULL,
    [EndDate]                   DATETIME      NULL,
    [ShortName]                 VARCHAR (15)  NULL,
    [NexusTypeId]               VARCHAR (100) NULL,
    [HasLocalNexus]             BIT           NOT NULL,
    [LocalNexusTypeId]          VARCHAR (100) NULL,
    [HasPermanentEstablishment] BIT           NOT NULL,
    [TaxId]                     VARCHAR (25)  NULL,
    [StreamlinedSalesTax]       BIT           NOT NULL,
    [AvalaraCreatedDate]        DATETIME      NULL,
    [AvalaraModifiedDate]       DATETIME      NULL,
    [CreatedUserId]             BIGINT        NOT NULL,
    [NexusTaxTypeGroup]         VARCHAR (100) NULL,
    [IsSellerImporterOfRecord]  BIT           NOT NULL,
    [CreatedTimestamp]          DATETIME      NOT NULL,
    CONSTRAINT [PK_AccountAvalaraNexus] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountAvalaraNexus_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountAvalaraNexus_AccountId]
    ON [dbo].[AccountAvalaraNexus]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

