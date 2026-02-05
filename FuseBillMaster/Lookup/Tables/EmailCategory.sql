CREATE TABLE [Lookup].[EmailCategory] (
    [Id]          INT           NOT NULL,
    [Name]        VARCHAR (50)  NOT NULL,
    [Description] VARCHAR (255) NOT NULL,
    [SortOrder]   TINYINT       NOT NULL,
    CONSTRAINT [PK_EmailCategory_1] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

