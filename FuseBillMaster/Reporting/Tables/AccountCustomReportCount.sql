CREATE TABLE [Reporting].[AccountCustomReportCount] (
    [AccountId]      BIGINT NOT NULL,
    [CountOfReports] INT    NOT NULL,
    CONSTRAINT [pk_AccountCustomReportCount] PRIMARY KEY CLUSTERED ([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_AccountCustomReportCount_AccountId] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id])
);


GO

