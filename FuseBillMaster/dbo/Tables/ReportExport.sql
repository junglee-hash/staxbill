CREATE TABLE [dbo].[ReportExport] (
    [Id]                      BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountId]               BIGINT          NOT NULL,
    [EntityTypeId]            INT             NOT NULL,
    [StatusId]                INT             NOT NULL,
    [Parameters]              VARCHAR (2000)  NULL,
    [CreatedTimestamp]        DATETIME        NOT NULL,
    [StartTimestamp]          DATETIME        NULL,
    [CompletedTimestamp]      DATETIME        NULL,
    [ExpiredTimestamp]        DATETIME        NULL,
    [CancelledTimestamp]      DATETIME        NULL,
    [DeletedTimestamp]        DATETIME        NULL,
    [LastDownloadedTimestamp] DATETIME        NULL,
    [Filesize]                DECIMAL (10, 2) NULL,
    [Filename]                VARCHAR (500)   NOT NULL,
    [ErrorTimestamp]          DATETIME        NULL,
    [ErrorReason]             VARCHAR (500)   NULL,
    [Reference]               NVARCHAR (255)  NULL,
    [EmailAttachment]         BIT             DEFAULT ((0)) NOT NULL,
    [CsvOutput]               BIT             CONSTRAINT [DF_DefaultCsvOutputReportExport] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ReportExport] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ReportExport_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_ReportExport_EntityType] FOREIGN KEY ([EntityTypeId]) REFERENCES [Lookup].[EntityType] ([Id]),
    CONSTRAINT [FK_ReportExport_ReportExportStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[ReportExportStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_ReportExport_AccountId_EntityTypeId_StatusId]
    ON [dbo].[ReportExport]([AccountId] ASC, [EntityTypeId] ASC, [StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

