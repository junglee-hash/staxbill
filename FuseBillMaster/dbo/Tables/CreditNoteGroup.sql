CREATE TABLE [dbo].[CreditNoteGroup] (
    [Id]                      BIGINT         IDENTITY (1, 1) NOT NULL,
    [InvoiceId]               BIGINT         NOT NULL,
    [Number]                  VARCHAR (255)  NULL,
    [NetsuiteId]              NVARCHAR (255) NULL,
    [CreditNoteGroupStatusId] INT            CONSTRAINT [DF_CreditNoteGroupStatusId] DEFAULT ((1)) NOT NULL,
    [Trigger]                 NVARCHAR (255) NULL,
    [TriggeringUserId]        BIGINT         NULL,
    CONSTRAINT [PK_CreditNotesLineItem] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CreditNoteGroup_CreditNoteStatus] FOREIGN KEY ([CreditNoteGroupStatusId]) REFERENCES [Lookup].[CreditNoteGroupStatus] ([Id]),
    CONSTRAINT [FK_CreditNoteGroup_Invoice] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_CreditNoteGroup_InvoiceId]
    ON [dbo].[CreditNoteGroup]([InvoiceId] ASC) WITH (FILLFACTOR = 100);


GO

