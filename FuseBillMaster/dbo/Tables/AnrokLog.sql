CREATE TABLE [dbo].[AnrokLog] (
    [Id]               BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]        BIGINT         NOT NULL,
    [CustomerId]       BIGINT         NULL,
    [DraftInvoiceId]   BIGINT         NULL,
    [InvoiceId]        BIGINT         NULL,
    [Input]            NVARCHAR (MAX) NOT NULL,
    [Output]           NVARCHAR (MAX) NULL,
    [FailureReason]    NVARCHAR (500) NULL,
    [CompletedIn]      INT            NOT NULL,
    [CreatedTimestamp] DATETIME       NOT NULL,
    [Committed]        BIT            NOT NULL,
    [TypeId]           INT            NOT NULL,
    [Successful]       BIT            NOT NULL,
    CONSTRAINT [pk_AnrokLog] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [fk_AnrokLog_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AnrokLog_AnrokLogType] FOREIGN KEY ([TypeId]) REFERENCES [Lookup].[AnrokLogType] ([Id]),
    CONSTRAINT [fk_AnrokLog_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [fk_AnrokLog_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_AnrokLog_AccountId_CustomerId_TypeId]
    ON [dbo].[AnrokLog]([AccountId] ASC, [CustomerId] ASC, [TypeId] ASC);


GO

