CREATE TABLE [Lookup].[AccountUploadType] (
    [Id]   TINYINT       NOT NULL,
    [Name] VARCHAR (255) NOT NULL,
    CONSTRAINT [PK_AccountUploadType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

