CREATE TABLE [dbo].[ReportScheduleParameter] (
    [Id]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [ReportScheduleId]      BIGINT          NOT NULL,
    [ReportParameterId]     TINYINT         NOT NULL,
    [ReportParameterTypeId] TINYINT         NOT NULL,
    [StringValue]           NVARCHAR (1000) NULL,
    [DateValue]             DATETIME        NULL,
    [NumericValue]          DECIMAL (18, 6) NULL,
    [EncryptionHash]        VARCHAR (1000)  NULL,
    CONSTRAINT [PK_ReportScheduleParameter] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ReportScheduleParameter_ReportParameterId] FOREIGN KEY ([ReportParameterId]) REFERENCES [Lookup].[ReportParameter] ([Id]),
    CONSTRAINT [FK_ReportScheduleParameter_ReportParameterTypeId] FOREIGN KEY ([ReportParameterTypeId]) REFERENCES [Lookup].[ReportParameterType] ([Id]),
    CONSTRAINT [FK_ReportScheduleParameter_ReportScheduleId] FOREIGN KEY ([ReportScheduleId]) REFERENCES [dbo].[ReportSchedule] ([Id])
);


GO

