CREATE TABLE [dbo].[PlanFrequency] (
    [Id]                            BIGINT        IDENTITY (1, 1) NOT NULL,
    [PlanRevisionId]                BIGINT        NOT NULL,
    [NumberOfIntervals]             INT           NOT NULL,
    [Interval]                      INT           NOT NULL,
    [StatusId]                      INT           CONSTRAINT [DF_PriceInterval_Status] DEFAULT ((1)) NOT NULL,
    [PlanFrequencyUniqueId]         BIGINT        NOT NULL,
    [NumberOfSubscriptions]         INT           NOT NULL,
    [RemainingInterval]             INT           NULL,
    [InvoiceInAdvance]              TINYINT       CONSTRAINT [DF_PlanFrequency_InvoiceInAdvance] DEFAULT ((0)) NOT NULL,
    [SalesforceId]                  VARCHAR (100) NULL,
    [RemainingRefreshPriceInterval] INT           NULL,
    CONSTRAINT [PK_IntervalPrice] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_IntervalPrice_PlanRevision] FOREIGN KEY ([PlanRevisionId]) REFERENCES [dbo].[PlanRevision] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [fk_PlanFrequency_PlanFrequencyKey] FOREIGN KEY ([PlanFrequencyUniqueId]) REFERENCES [dbo].[PlanFrequencyKey] ([Id]),
    CONSTRAINT [FK_PlanInterval_Interval] FOREIGN KEY ([Interval]) REFERENCES [Lookup].[Interval] ([Id]),
    CONSTRAINT [FK_PriceInterval_PriceIntervalStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[PriceIntervalStatus] ([Id]),
    CONSTRAINT [UK_PlanFrequency_Interval_NumberofIntervals] UNIQUE NONCLUSTERED ([PlanRevisionId] ASC, [Interval] ASC, [NumberOfIntervals] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [IX_PlanFrequency_Interval]
    ON [dbo].[PlanFrequency]([Interval] ASC)
    INCLUDE([Id], [NumberOfIntervals]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PlanFrequency_PlanRevisionId]
    ON [dbo].[PlanFrequency]([PlanRevisionId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_PlanFrequency_PlanFrequencyUniqueId]
    ON [dbo].[PlanFrequency]([PlanFrequencyUniqueId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PlanFrequency_StatusId]
    ON [dbo].[PlanFrequency]([StatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

