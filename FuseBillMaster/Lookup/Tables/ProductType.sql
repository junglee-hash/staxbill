CREATE TABLE [Lookup].[ProductType] (
    [Id]        INT            NOT NULL,
    [Name]      NVARCHAR (100) NOT NULL,
    [SortOrder] TINYINT        NOT NULL,
    CONSTRAINT [PK_ProductType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

