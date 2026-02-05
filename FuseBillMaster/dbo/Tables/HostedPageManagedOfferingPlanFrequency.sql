CREATE TABLE [dbo].[HostedPageManagedOfferingPlanFrequency] (
    [Id]                              BIGINT        IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedOfferingPlanId] BIGINT        NOT NULL,
    [PlanFrequencyKeyId]              BIGINT        NOT NULL,
    [Visible]                         BIT           NOT NULL,
    [IsDefault]                       BIT           NOT NULL,
    [DisplayName]                     VARCHAR (255) NULL,
    CONSTRAINT [PK_HostedPageManagedOfferingPlanFrequency] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedOfferingPlanFrequency_HostedPageManagedOfferingPlan] FOREIGN KEY ([HostedPageManagedOfferingPlanId]) REFERENCES [dbo].[HostedPageManagedOfferingPlan] ([Id]),
    CONSTRAINT [FK_HostedPageManagedOfferingPlanFrequency_PlanFrequencyKeyId] FOREIGN KEY ([PlanFrequencyKeyId]) REFERENCES [dbo].[PlanFrequencyKey] ([Id])
);


GO

