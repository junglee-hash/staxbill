CREATE TABLE [Lookup].[LateInvoicesOption] (
    [Id]   TINYINT       NOT NULL,
    [Name] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_LateInvoicesOption] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

