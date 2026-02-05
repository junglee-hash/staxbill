CREATE TABLE [Dim].[Date] (
    [DateKey]           BIGINT    NOT NULL,
    [FullDate]          DATETIME  NULL,
    [DateName]          CHAR (11) NULL,
    [DateNameUS]        CHAR (11) NULL,
    [DateNameEU]        CHAR (11) NULL,
    [DayOfWeek]         TINYINT   NULL,
    [DayNameOfWeek]     CHAR (10) NULL,
    [DayOfMonth]        TINYINT   NULL,
    [DayOfYear]         SMALLINT  NULL,
    [WeekdayWeekend]    CHAR (7)  NULL,
    [WeekOfYear]        TINYINT   NULL,
    [MonthName]         CHAR (10) NULL,
    [MonthOfYear]       TINYINT   NULL,
    [IsLastDayOfMonth]  CHAR (1)  NULL,
    [CalendarQuarter]   TINYINT   NULL,
    [CalendarYear]      SMALLINT  NULL,
    [CalendarYearMonth] CHAR (7)  NULL,
    [CalendarYearQtr]   CHAR (7)  NULL,
    [AuditKey]          BIGINT    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateKey] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [IX_Date_IsLastDayOfMonth_FullDate]
    ON [Dim].[Date]([IsLastDayOfMonth] ASC, [FullDate] ASC)
    INCLUDE([MonthName], [MonthOfYear], [CalendarYear]) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_Dim_Date_FullDate_DayOfMonth]
    ON [Dim].[Date]([FullDate] ASC, [DayOfMonth] ASC) WITH (FILLFACTOR = 100);


GO

