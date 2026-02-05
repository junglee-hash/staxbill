CREATE TABLE [Lookup].[NetsuiteInvoiceErrorReason] (
    [Id]   TINYINT       NOT NULL,
    [Name] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_​NetsuiteInvoiceErrorReason] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80)
);


GO

