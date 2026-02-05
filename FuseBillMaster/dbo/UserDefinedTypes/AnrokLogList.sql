CREATE TYPE [dbo].[AnrokLogList] AS TABLE (
    [AnrokLogId]     BIGINT NOT NULL,
    [DraftInvoiceId] BIGINT NULL,
    [InvoiceId]      BIGINT NULL,
    [CustomerId]     BIGINT NULL,
    PRIMARY KEY CLUSTERED ([AnrokLogId] ASC));


GO

