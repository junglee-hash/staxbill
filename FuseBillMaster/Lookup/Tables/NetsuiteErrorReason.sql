CREATE TABLE [Lookup].[NetsuiteErrorReason] (
    [Id]           TINYINT        NOT NULL,
    [Name]         VARCHAR (100)  NOT NULL,
    [ErrorMessage] VARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_​NetsuiteErrorReason] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80)
);


GO

