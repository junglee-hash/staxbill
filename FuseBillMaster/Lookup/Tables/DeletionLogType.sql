CREATE TABLE [Lookup].[DeletionLogType] (
    [Id]   INT           NOT NULL,
    [Name] VARCHAR (255) NOT NULL,
    CONSTRAINT [PK_DeletionLogType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

