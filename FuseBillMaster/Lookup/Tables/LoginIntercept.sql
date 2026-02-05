CREATE TABLE [Lookup].[LoginIntercept] (
    [Id]                TINYINT        NOT NULL,
    [Name]              NVARCHAR (100) NOT NULL,
    [SortOrder]         TINYINT        NOT NULL,
    [UserCreatedBefore] DATETIME       NULL,
    CONSTRAINT [PK_LoginIntercept] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

