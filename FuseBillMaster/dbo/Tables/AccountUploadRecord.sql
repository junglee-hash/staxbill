CREATE TABLE [dbo].[AccountUploadRecord] (
    [Id]                          BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountUploadId]             BIGINT          NOT NULL,
    [AccountUploadRecordStatusId] TINYINT         NOT NULL,
    [CreatedTimestamp]            DATETIME        NOT NULL,
    [Data]                        NVARCHAR (MAX)  NOT NULL,
    [Details]                     NVARCHAR (1000) NULL,
    [CreatedEntityId]             BIGINT          NULL,
    [JsonData]                    NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_AccountUploadRecord] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountUploadRecord_AccountUpload] FOREIGN KEY ([AccountUploadId]) REFERENCES [dbo].[AccountUpload] ([Id]),
    CONSTRAINT [FK_AccountUploadRecord_AccountUploadRecordStatus] FOREIGN KEY ([AccountUploadRecordStatusId]) REFERENCES [Lookup].[AccountUploadRecordStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountUploadRecord_AccountUploadRecordStatusId]
    ON [dbo].[AccountUploadRecord]([AccountUploadRecordStatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountUploadRecord_AccountUploadId]
    ON [dbo].[AccountUploadRecord]([AccountUploadId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

