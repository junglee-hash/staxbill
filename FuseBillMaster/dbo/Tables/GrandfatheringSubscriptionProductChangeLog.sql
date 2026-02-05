CREATE TABLE [dbo].[GrandfatheringSubscriptionProductChangeLog] (
    [Id]                    BIGINT   IDENTITY (1, 1) NOT NULL,
    [SubscriptionProductId] BIGINT   NOT NULL,
    [OldPlanProductId]      BIGINT   NULL,
    [NewPlanProductId]      BIGINT   NOT NULL,
    [CreatedTimestamp]      DATETIME CONSTRAINT [df_GrandfatheringSubscriptionProductChangeLog_CreatedTimestamp] DEFAULT (getutcdate()) NOT NULL,
    [OldStatusId]           INT      NULL,
    [NewStatusId]           INT      NULL,
    CONSTRAINT [pk_GrandfatheringSubscriptionProductChangeLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

