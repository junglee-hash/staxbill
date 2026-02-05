CREATE TABLE [dbo].[VoidReverseCharge] (
    [Id]                       BIGINT         NOT NULL,
    [Reference]                NVARCHAR (500) NULL,
    [OriginalReverseChargeId]  BIGINT         NOT NULL,
    [CreditNoteId]             BIGINT         NOT NULL,
    [QuickBooksId]             BIGINT         NULL,
    [QuickBooksAttemptNumber]  INT            CONSTRAINT [DF_QBAttemptNumber] DEFAULT ((0)) NOT NULL,
    [IsQuickBooksRequeue]      BIT            NULL,
    [IsQuickBooksBlock]        BIT            NULL,
    [SageIntacctId]            BIGINT         NULL,
    [SageIntacctAttemptNumber] INT            CONSTRAINT [DF_VoidReverseChargeOffSageIntacctAttemptNumber] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_VoidReverseCharge] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_VoidReverseCharge_CreditNote] FOREIGN KEY ([CreditNoteId]) REFERENCES [dbo].[CreditNote] ([Id]),
    CONSTRAINT [FK_VoidReverseCharge_OriginalReverseCharge] FOREIGN KEY ([OriginalReverseChargeId]) REFERENCES [dbo].[ReverseCharge] ([Id]),
    CONSTRAINT [FK_VoidReverseCharge_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

