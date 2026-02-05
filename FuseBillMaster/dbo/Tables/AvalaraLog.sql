CREATE TABLE [dbo].[AvalaraLog] (
    [Id]                      BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]               BIGINT         NOT NULL,
    [CustomerId]              BIGINT         NULL,
    [Input]                   NVARCHAR (MAX) NOT NULL,
    [Output]                  NVARCHAR (MAX) NOT NULL,
    [FailureReason]           NVARCHAR (500) NOT NULL,
    [CompletedIn]             INT            NOT NULL,
    [CreatedTimestamp]        DATETIME       NOT NULL,
    [Committed]               BIT            CONSTRAINT [DF_CommittedDefault] DEFAULT ((0)) NOT NULL,
    [DevMode]                 BIT            NULL,
    [AccountNumber]           NVARCHAR (255) NULL,
    [DraftInvoiceId]          BIGINT         NULL,
    [InvoiceId]               BIGINT         NULL,
    [TypeId]                  INT            NOT NULL,
    [DocCode]                 NVARCHAR (255) NULL,
    [Compressed]              BIT            CONSTRAINT [DF_Compressed] DEFAULT ((0)) NOT NULL,
    [AvalaraOrganizationCode] NVARCHAR (255) NULL,
    [StatusId]                TINYINT        NULL,
    CONSTRAINT [pk_AvalaraLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_AvalaraLog_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AvalaraLog_AvalaraLogStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[AvalaraLogStatus] ([Id]),
    CONSTRAINT [fk_AvalaraLog_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [fk_AvalaraLog_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_AvalaraLog_InvoiceId_AccountId]
    ON [dbo].[AvalaraLog]([InvoiceId] ASC, [AccountId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_AvalaraLog_AccountId]
    ON [dbo].[AvalaraLog]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_AvalaraLog_CreatedTimestamp]
    ON [dbo].[AvalaraLog]([CreatedTimestamp] ASC) WITH (FILLFACTOR = 100);


GO

