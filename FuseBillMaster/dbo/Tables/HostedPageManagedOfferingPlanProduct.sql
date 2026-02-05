CREATE TABLE [dbo].[HostedPageManagedOfferingPlanProduct] (
    [Id]                              BIGINT IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedOfferingPlanId] BIGINT NOT NULL,
    [PlanProductKeyId]                BIGINT NOT NULL,
    [Visible]                         BIT    NOT NULL,
    [QuantityManagement]              BIT    NOT NULL,
    [InclusionManagement]             BIT    NOT NULL,
    CONSTRAINT [PK_HostedPageManagedOfferingPlanProduct] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedOfferingPlanProduct_HostedPageManagedOfferingPlan] FOREIGN KEY ([HostedPageManagedOfferingPlanId]) REFERENCES [dbo].[HostedPageManagedOfferingPlan] ([Id]),
    CONSTRAINT [FK_HostedPageManagedOfferingPlanProduct_PlanProductKeyId] FOREIGN KEY ([PlanProductKeyId]) REFERENCES [dbo].[PlanProductKey] ([Id])
);


GO

