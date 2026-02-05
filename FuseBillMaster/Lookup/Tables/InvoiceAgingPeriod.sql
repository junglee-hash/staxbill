CREATE TABLE [Lookup].[InvoiceAgingPeriod] (
    [Terms]    VARCHAR (60)    NOT NULL,
    [Startday] DECIMAL (20, 2) NOT NULL,
    [EndDay]   DECIMAL (20, 2) NOT NULL,
    CONSTRAINT [PK_InvoiceAgingPeriod] PRIMARY KEY CLUSTERED ([Startday] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

