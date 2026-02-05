CREATE TABLE [dbo].[InvoiceRevision] (
    [Id]               BIGINT          IDENTITY (1, 1) NOT NULL,
    [InvoiceId]        BIGINT          NOT NULL,
    [UserId]           BIGINT          NULL,
    [PoNumber]         VARCHAR (255)   NULL,
    [Notes]            NVARCHAR (4000) NULL,
    [Reason]           NVARCHAR (100)  NULL,
    [CreatedTimestamp] DATETIME        NOT NULL,
    [ReferenceDate]    DATETIME        NULL,
    CONSTRAINT [PK_InvoiceRevision] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_InvoiceRevision_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id]),
    CONSTRAINT [FK_InvoiceRevision_User] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_InvoiceRevision_InvoiceId_CreatedTimestamp]
    ON [dbo].[InvoiceRevision]([InvoiceId] ASC, [CreatedTimestamp] ASC) WITH (FILLFACTOR = 100);


GO

