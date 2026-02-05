CREATE TABLE [Reporting].[dimInvoiceDetailInvoicesWithScheduleStageData] (
    [InvoiceId]        BIGINT NOT NULL,
    [InstallmentCount] INT    NOT NULL,
    PRIMARY KEY CLUSTERED ([InvoiceId] ASC)
);


GO

