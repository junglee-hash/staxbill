CREATE TABLE [Lookup].[PageIntercept] (
    [Id]               TINYINT        NOT NULL,
    [Name]             NVARCHAR (100) NOT NULL,
    [SourceController] NVARCHAR (100) NOT NULL,
    [SourceAction]     NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_PageIntercept] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

