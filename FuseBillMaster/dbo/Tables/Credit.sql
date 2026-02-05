CREATE TABLE [dbo].[Credit] (
    [Id]                       BIGINT          NOT NULL,
    [Reference]                NVARCHAR (255)  NULL,
    [UnallocatedAmount]        DECIMAL (18, 6) NOT NULL,
    [ReversableAmount]         DECIMAL (18, 6) NOT NULL,
    [QuickBooksId]             BIGINT          NULL,
    [QuickBooksAttemptNumber]  INT             CONSTRAINT [df_CreditQuickBooksAttemptNumber] DEFAULT ((0)) NOT NULL,
    [NetsuiteId]               NVARCHAR (255)  NULL,
    [NetsuiteItemId]           NVARCHAR (255)  NULL,
    [Trigger]                  NVARCHAR (255)  NULL,
    [TriggeringUserId]         BIGINT          NULL,
    [SalesTrackingCode1Id]     BIGINT          NULL,
    [SalesTrackingCode2Id]     BIGINT          NULL,
    [SalesTrackingCode3Id]     BIGINT          NULL,
    [SalesTrackingCode4Id]     BIGINT          NULL,
    [SalesTrackingCode5Id]     BIGINT          NULL,
    [IsQuickBooksRequeue]      BIT             NULL,
    [IsQuickBooksBlock]        BIT             NULL,
    [SageIntacctId]            BIGINT          NULL,
    [SageIntacctAttemptNumber] INT             CONSTRAINT [DF_CreditSageIntacctAttemptNumber] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Credit] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Credit_SalesTrackingCode1] FOREIGN KEY ([SalesTrackingCode1Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Credit_SalesTrackingCode2] FOREIGN KEY ([SalesTrackingCode2Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Credit_SalesTrackingCode3] FOREIGN KEY ([SalesTrackingCode3Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Credit_SalesTrackingCode4] FOREIGN KEY ([SalesTrackingCode4Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Credit_SalesTrackingCode5] FOREIGN KEY ([SalesTrackingCode5Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_Credit_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

