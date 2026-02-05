CREATE TABLE [dbo].[WriteOff] (
    [Id]                       BIGINT         NOT NULL,
    [InvoiceId]                BIGINT         NOT NULL,
    [Reference]                NVARCHAR (500) NULL,
    [QuickBooksId]             BIGINT         NULL,
    [QuickBooksAttemptNumber]  INT            CONSTRAINT [df_WriteOffQuickBooksAttemptNumber] DEFAULT ((0)) NOT NULL,
    [NetsuiteId]               NVARCHAR (255) NULL,
    [IsQuickBooksRequeue]      BIT            NULL,
    [IsQuickBooksBlock]        BIT            NULL,
    [SageIntacctId]            BIGINT         NULL,
    [SageIntacctAttemptNumber] INT            CONSTRAINT [DF_WriteOffSageIntacctAttemptNumber] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_WriteOff] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_WriteOff_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id]),
    CONSTRAINT [FK_WriteOff_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_WriteOff_InvoiceId]
    ON [dbo].[WriteOff]([InvoiceId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

