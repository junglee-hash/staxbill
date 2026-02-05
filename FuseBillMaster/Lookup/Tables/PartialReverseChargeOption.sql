CREATE TABLE [Lookup].[PartialReverseChargeOption] (
    [Id]   TINYINT       NOT NULL,
    [Name] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_PartialReverseChargeOption] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

