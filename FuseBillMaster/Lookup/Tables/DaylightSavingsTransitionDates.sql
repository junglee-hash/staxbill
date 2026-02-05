CREATE TABLE [Lookup].[DaylightSavingsTransitionDates] (
    [ClrId]           NVARCHAR (500) NOT NULL,
    [TransitionStart] DATETIME       NOT NULL,
    [TransitionEnd]   DATETIME       NOT NULL,
    [Hours]           INT            NOT NULL,
    [Minutes]         INT            NOT NULL,
    [Id]              BIGINT         NOT NULL,
    CONSTRAINT [PK_DaylightSavingsTransitionDates] PRIMARY KEY CLUSTERED ([Id] ASC, [TransitionStart] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

