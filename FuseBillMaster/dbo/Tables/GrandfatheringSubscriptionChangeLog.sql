CREATE TABLE [dbo].[GrandfatheringSubscriptionChangeLog] (
    [Id]                 BIGINT   IDENTITY (1, 1) NOT NULL,
    [SubscriptionId]     BIGINT   NOT NULL,
    [OldPlanFrequencyId] BIGINT   NOT NULL,
    [NewPlanFrequencyId] BIGINT   NOT NULL,
    [CreatedTimestamp]   DATETIME CONSTRAINT [df_GrandfatheringSubscriptionChangeLog_CreatedTimestamp] DEFAULT (getutcdate()) NOT NULL,
    CONSTRAINT [pk_GrandfatheringSubscriptionChangeLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

