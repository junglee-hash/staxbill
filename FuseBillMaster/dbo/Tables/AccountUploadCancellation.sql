CREATE TABLE [dbo].[AccountUploadCancellation] (
    [Id]               BIGINT   IDENTITY (1, 1) NOT NULL,
    [AccountId]        BIGINT   NOT NULL,
    [AccountUploadId]  BIGINT   NOT NULL,
    [CreatedTimestamp] DATETIME NOT NULL,
    CONSTRAINT [PK_AccountUploadCancellation] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100)
);


GO

CREATE NONCLUSTERED INDEX [IX_AccountUploadCancellation_AccountId_AccountUploadId]
    ON [dbo].[AccountUploadCancellation]([AccountId] ASC, [AccountUploadId] ASC) WITH (FILLFACTOR = 100);


GO

