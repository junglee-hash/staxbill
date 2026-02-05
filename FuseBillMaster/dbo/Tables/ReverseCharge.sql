CREATE TABLE [dbo].[ReverseCharge] (
    [Id]                       BIGINT         NOT NULL,
    [Reference]                NVARCHAR (500) NULL,
    [OriginalChargeId]         BIGINT         NOT NULL,
    [CreditNoteId]             BIGINT         NOT NULL,
    [QuickBooksId]             BIGINT         NULL,
    [QuickBooksAttemptNumber]  INT            CONSTRAINT [df_ReverseChargeQuickBooksAttemptNumber] DEFAULT ((0)) NOT NULL,
    [IsQuickBooksRequeue]      BIT            NULL,
    [IsQuickBooksBlock]        BIT            NULL,
    [SageIntacctId]            BIGINT         NULL,
    [SageIntacctAttemptNumber] INT            CONSTRAINT [DF_ReverseChargeOffSageIntacctAttemptNumber] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ReverseCharge] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ReverseCharge_CreditNote] FOREIGN KEY ([CreditNoteId]) REFERENCES [dbo].[CreditNote] ([Id]),
    CONSTRAINT [FK_ReverseCharge_OriginalCharge] FOREIGN KEY ([OriginalChargeId]) REFERENCES [dbo].[Charge] ([Id]),
    CONSTRAINT [FK_ReverseCharge_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_ReverseCharge_CreditNoteId]
    ON [dbo].[ReverseCharge]([CreditNoteId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_ReverseCharge_OriginalChargeId]
    ON [dbo].[ReverseCharge]([OriginalChargeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

