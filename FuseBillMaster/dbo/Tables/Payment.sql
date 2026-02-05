CREATE TABLE [dbo].[Payment] (
    [Id]                       BIGINT          NOT NULL,
    [Reference]                NVARCHAR (500)  NULL,
    [PaymentActivityJournalId] BIGINT          NOT NULL,
    [RefundableAmount]         DECIMAL (18, 6) NOT NULL,
    [UnallocatedAmount]        DECIMAL (18, 6) NOT NULL,
    [QuickBooksId]             BIGINT          NULL,
    [QuickBooksAttemptNumber]  INT             CONSTRAINT [df_PaymentQuickBooksAttemptNumber] DEFAULT ((0)) NOT NULL,
    [GatewayFee]               DECIMAL (18, 6) NULL,
    [SalesTrackingCode1Id]     BIGINT          NULL,
    [SalesTrackingCode2Id]     BIGINT          NULL,
    [SalesTrackingCode3Id]     BIGINT          NULL,
    [SalesTrackingCode4Id]     BIGINT          NULL,
    [SalesTrackingCode5Id]     BIGINT          NULL,
    [NetsuiteId]               NVARCHAR (255)  NULL,
    [PendingGatewayFee]        BIT             CONSTRAINT [DF_Payment_PendingGatewayFee] DEFAULT ((0)) NOT NULL,
    [ReferenceDate]            DATETIME        NULL,
    [SendToNetsuite]           BIT             CONSTRAINT [DF_SendToNetsuite] DEFAULT ((1)) NOT NULL,
    [IsQuickBooksRequeue]      BIT             NULL,
    [IsQuickBooksBlock]        BIT             NULL,
    [SendToQuickbooksOnline]   BIT             CONSTRAINT [DF_SendToQuickbooksOnline_TRUE] DEFAULT ((1)) NOT NULL,
    [SageIntacctId]            BIGINT          NULL,
    [SageIntacctAttemptNumber] INT             CONSTRAINT [DF_PaymentSageIntacctAttemptNumber] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Payment] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Payment_PaymentActivityJournal] FOREIGN KEY ([PaymentActivityJournalId]) REFERENCES [dbo].[PaymentActivityJournal] ([Id]),
    CONSTRAINT [FK_Payment_SalesTrackingCode1] FOREIGN KEY ([SalesTrackingCode1Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Payment_SalesTrackingCode2] FOREIGN KEY ([SalesTrackingCode2Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Payment_SalesTrackingCode3] FOREIGN KEY ([SalesTrackingCode3Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Payment_SalesTrackingCode4] FOREIGN KEY ([SalesTrackingCode4Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Payment_SalesTrackingCode5] FOREIGN KEY ([SalesTrackingCode5Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Payment_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [IX_Payment_UnallocatedAmount]
    ON [dbo].[Payment]([UnallocatedAmount] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_Payment_PaymentActivityJournalId]
    ON [dbo].[Payment]([PaymentActivityJournalId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

