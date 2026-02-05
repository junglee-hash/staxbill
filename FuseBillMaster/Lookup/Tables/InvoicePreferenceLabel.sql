CREATE TABLE [Lookup].[InvoicePreferenceLabel] (
    [Id]           INT           NOT NULL,
    [Name]         VARCHAR (50)  NOT NULL,
    [DefaultLabel] NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_InvoicePreferenceLabel] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

