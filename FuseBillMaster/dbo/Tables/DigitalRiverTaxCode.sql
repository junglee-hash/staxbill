CREATE TABLE [dbo].[DigitalRiverTaxCode] (
    [Id]                        BIGINT         IDENTITY (1, 1) NOT NULL,
    [Type]                      NVARCHAR (125) NOT NULL,
    [TaxCode]                   VARCHAR (25)   NOT NULL,
    [DigitalRiverProductTypeId] INT            NOT NULL,
    CONSTRAINT [PK_DigitalRiverTaxCode] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DigitalRiverTaxCode_DigitalRiverProductType] FOREIGN KEY ([DigitalRiverProductTypeId]) REFERENCES [Lookup].[DigitalRiverProductType] ([Id])
);


GO

