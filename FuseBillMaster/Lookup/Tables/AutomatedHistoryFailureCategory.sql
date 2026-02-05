CREATE TABLE [Lookup].[AutomatedHistoryFailureCategory] (
    [Id]   TINYINT      NOT NULL,
    [Name] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_AutomatedHistoryFailureCategory] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

