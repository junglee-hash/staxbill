CREATE TABLE [dbo].[AccountUpload] (
    [Id]                     BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]              BIGINT         NOT NULL,
    [AccountUploadTypeId]    TINYINT        NOT NULL,
    [AccountUploadStatusId]  TINYINT        NOT NULL,
    [CreatedTimestamp]       DATETIME       NOT NULL,
    [CompletedTimestamp]     DATETIME       NULL,
    [TotalRecords]           INT            NULL,
    [SuccessfulRecords]      INT            NULL,
    [FailedRecords]          INT            NULL,
    [FieldMap]               NVARCHAR (MAX) NULL,
    [FileName]               NVARCHAR (255) NULL,
    [TotalProcessed]         INT            NULL,
    [TotalFailedProcessing]  INT            NULL,
    [ImportingTimestamp]     DATETIME       NULL,
    [ProcessedTimestamp]     DATETIME       NULL,
    [Reference]              NVARCHAR (255) NULL,
    [Settings]               VARCHAR (2000) NULL,
    [TotalProcessedRecords]  INT            NULL,
    [AccountUploadRelatedId] BIGINT         NULL,
    [InternalAutomatedFlag]  BIT            CONSTRAINT [DF_InternalAutomatedJob] DEFAULT ((0)) NOT NULL,
    [ModifiedTimestamp]      DATETIME       CONSTRAINT [DF_AccountUploadModifiedTimestamp] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [PK_AccountUpload] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountUpload_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountUpload_AccountUpload] FOREIGN KEY ([AccountUploadRelatedId]) REFERENCES [dbo].[AccountUpload] ([Id]),
    CONSTRAINT [FK_AccountUpload_AccountUploadStatus] FOREIGN KEY ([AccountUploadStatusId]) REFERENCES [Lookup].[AccountUploadStatus] ([Id]),
    CONSTRAINT [FK_AccountUpload_AccountUploadType] FOREIGN KEY ([AccountUploadTypeId]) REFERENCES [Lookup].[AccountUploadType] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountUpload_AccountId]
    ON [dbo].[AccountUpload]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountUpload_AccountUploadTypeId]
    ON [dbo].[AccountUpload]([AccountUploadTypeId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_AccountUpload_AccountUploadStatusId_CreatedTimestamp]
    ON [dbo].[AccountUpload]([AccountUploadStatusId] ASC, [CreatedTimestamp] ASC) WITH (FILLFACTOR = 100);


GO

