CREATE TABLE [dbo].[Debit] (
    [Id]                       BIGINT         NOT NULL,
    [Reference]                NVARCHAR (500) NULL,
    [OriginalCreditId]         BIGINT         NOT NULL,
    [QuickBooksId]             BIGINT         NULL,
    [QuickBooksAttemptNumber]  INT            CONSTRAINT [df_DebitQuickBooksAttemptNumber] DEFAULT ((0)) NOT NULL,
    [NetsuiteId]               NVARCHAR (255) NULL,
    [Trigger]                  NVARCHAR (255) NULL,
    [TriggeringUserId]         BIGINT         NULL,
    [IsQuickBooksRequeue]      BIT            NULL,
    [IsQuickBooksBlock]        BIT            NULL,
    [SageIntacctId]            BIGINT         NULL,
    [SageIntacctAttemptNumber] INT            CONSTRAINT [DF_DebitSageIntacctAttemptNumber] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Debit] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Debit_Credit] FOREIGN KEY ([OriginalCreditId]) REFERENCES [dbo].[Credit] ([Id]),
    CONSTRAINT [FK_Debit_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_Debit_OriginalCreditId]
    ON [dbo].[Debit]([OriginalCreditId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

