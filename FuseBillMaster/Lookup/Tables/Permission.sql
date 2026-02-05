CREATE TABLE [Lookup].[Permission] (
    [Id]        BIGINT        NOT NULL,
    [Name]      VARCHAR (200) NOT NULL,
    [ParentId]  INT           NULL,
    [SortOrder] INT           NOT NULL,
    CONSTRAINT [PK__lkPermission] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

