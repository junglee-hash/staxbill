CREATE TABLE [dbo].[Report] (
    [Id]                   BIGINT        IDENTITY (1, 1) NOT NULL,
    [AccountId]            BIGINT        NOT NULL,
    [Name]                 VARCHAR (50)  NOT NULL,
    [Description]          VARCHAR (255) NULL,
    [StatusId]             TINYINT       NOT NULL,
    [StoredProcedure]      VARCHAR (255) NOT NULL,
    [OptionId]             TINYINT       NOT NULL,
    [CreatedTimestamp]     DATETIME      NOT NULL,
    [ModifiedTimestamp]    DATETIME      NOT NULL,
    [DatabaseInstanceId]   TINYINT       CONSTRAINT [df_DatabaseInstanceId] DEFAULT ((1)) NOT NULL,
    [EntityTypeId]         INT           DEFAULT ((23)) NOT NULL,
    [ReportInputTypeId]    INT           NULL,
    [FilenameFormatTypeId] TINYINT       CONSTRAINT [DF_DefaultFilenameFormatTypeId] DEFAULT ((1)) NOT NULL,
    [CsvOutput]            BIT           CONSTRAINT [DF_DefaultCsvOutput] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Report] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Report_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_Report_DatabaseInstance] FOREIGN KEY ([DatabaseInstanceId]) REFERENCES [Lookup].[ReportDatabaseInstance] ([Id]),
    CONSTRAINT [FK_Report_EntityTypeId] FOREIGN KEY ([EntityTypeId]) REFERENCES [Lookup].[EntityType] ([Id]),
    CONSTRAINT [FK_Report_Option] FOREIGN KEY ([OptionId]) REFERENCES [Lookup].[ReportOption] ([Id]),
    CONSTRAINT [FK_Report_ReportInputType] FOREIGN KEY ([ReportInputTypeId]) REFERENCES [Lookup].[ReportInputType] ([Id]),
    CONSTRAINT [FK_Report_Status] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[ReportStatus] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_Report_AccountId]
    ON [dbo].[Report]([AccountId] ASC) WITH (FILLFACTOR = 100);


GO

