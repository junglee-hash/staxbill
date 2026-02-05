CREATE TABLE [dbo].[SecurityQuestion] (
    [Id]   BIGINT        NOT NULL,
    [Name] VARCHAR (255) NOT NULL,
    CONSTRAINT [PK_SecurityQuestion] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

