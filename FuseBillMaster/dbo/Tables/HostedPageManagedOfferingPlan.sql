CREATE TABLE [dbo].[HostedPageManagedOfferingPlan] (
    [Id]                          BIGINT          IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedOfferingId] BIGINT          NOT NULL,
    [PlanId]                      BIGINT          NOT NULL,
    [TitleText]                   NVARCHAR (100)  NOT NULL,
    [DescriptionText]             NVARCHAR (1000) NULL,
    [ButtonText]                  NVARCHAR (50)   NOT NULL,
    [Visible]                     BIT             NOT NULL,
    [SortOrder]                   INT             NOT NULL,
    [IsHighlighted]               BIT             CONSTRAINT [DF_IsHighlighted_Default] DEFAULT ((0)) NOT NULL,
    [FrequenciesPageTitle]        NVARCHAR (100)  CONSTRAINT [DF_FrequenciesPageTitle_Default] DEFAULT ('Choose a payment frequency') NOT NULL,
    CONSTRAINT [PK_HostedPageManagedOfferingPlan] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedOfferingPlan_HostedPageManagedOffering] FOREIGN KEY ([HostedPageManagedOfferingId]) REFERENCES [dbo].[HostedPageManagedOffering] ([Id]),
    CONSTRAINT [FK_HostedPageManagedOfferingPlan_Plan] FOREIGN KEY ([PlanId]) REFERENCES [dbo].[Plan] ([Id]),
    CONSTRAINT [uk_OfferingPlan] UNIQUE NONCLUSTERED ([HostedPageManagedOfferingId] ASC, [PlanId] ASC) WITH (FILLFACTOR = 100)
);


GO

