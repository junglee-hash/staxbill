CREATE TABLE [Lookup].[InvoiceCustomerReferenceOption] (
    [Id]   INT          NOT NULL,
    [Name] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_InvoiceCustomerReferenceOption] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

