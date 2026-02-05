CREATE TABLE [dbo].[ReportSchedule] (
    [Id]                         BIGINT          IDENTITY (1, 1) NOT NULL,
    [ReportId]                   BIGINT          NOT NULL,
    [IntervalId]                 TINYINT         NOT NULL,
    [Day]                        INT             NULL,
    [Month]                      INT             NULL,
    [Email]                      NVARCHAR (1000) NULL,
    [LastRunTimestamp]           DATETIME        NULL,
    [NextRunTimestamp]           DATETIME        NULL,
    [IsToDate]                   BIT             NULL,
    [RangeIntervalId]            INT             NULL,
    [NumberOfPeriods]            INT             NULL,
    [ReportDeliveryOptionId]     TINYINT         CONSTRAINT [DF_ReportDeliveryOptionId] DEFAULT ((1)) NOT NULL,
    [ReportNotificationOptionId] TINYINT         CONSTRAINT [DF_ReportNotificationOptionId] DEFAULT ((1)) NOT NULL,
    [Hour]                       TINYINT         DEFAULT ((0)) NOT NULL,
    [IsInFuture]                 BIT             CONSTRAINT [DF_IsInFuture] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ReportSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_Report_Interval] FOREIGN KEY ([IntervalId]) REFERENCES [Lookup].[ReportInterval] ([Id]),
    CONSTRAINT [FK_Report_RangeInterval] FOREIGN KEY ([RangeIntervalId]) REFERENCES [Lookup].[Interval] ([Id]),
    CONSTRAINT [FK_Report_Schedule] FOREIGN KEY ([ReportId]) REFERENCES [dbo].[Report] ([Id]),
    CONSTRAINT [FK_ReportSchedule_ReportDeliveryOptionId] FOREIGN KEY ([ReportDeliveryOptionId]) REFERENCES [Lookup].[ReportDeliveryOption] ([Id]),
    CONSTRAINT [FK_ReportSchedule_ReportNotificationOptionId] FOREIGN KEY ([ReportNotificationOptionId]) REFERENCES [Lookup].[ReportNotificationOption] ([Id])
);


GO

