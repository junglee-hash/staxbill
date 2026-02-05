CREATE TABLE [dbo].[CustomerEmailLogAttachment] (
    [Id]                 BIGINT        IDENTITY (1, 1) NOT NULL,
    [CustomerEmailLogId] BIGINT        NOT NULL,
    [AttachmentName]     VARCHAR (255) NOT NULL,
    CONSTRAINT [PK_CustomerEmailLogAttachment] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_CustomerEmailLogAttachment_CustomerEmailLog] FOREIGN KEY ([CustomerEmailLogId]) REFERENCES [dbo].[CustomerEmailLog] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerEmailLogAttachment_CustomerEmailLogId]
    ON [dbo].[CustomerEmailLogAttachment]([CustomerEmailLogId] ASC) WITH (FILLFACTOR = 100);


GO

