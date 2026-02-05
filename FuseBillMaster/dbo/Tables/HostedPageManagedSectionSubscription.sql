CREATE TABLE [dbo].[HostedPageManagedSectionSubscription] (
    [Id]                                       BIGINT          NOT NULL,
    [QuantityManagementId]                     TINYINT         NOT NULL,
    [InclusionManagementId]                    TINYINT         NOT NULL,
    [EnableRenewalButton]                      BIT             CONSTRAINT [df_EnableRenewalButton] DEFAULT ((0)) NOT NULL,
    [RenewalButtonLabel]                       NVARCHAR (100)  NULL,
    [RenewalButtonMonthlySetting]              INT             NULL,
    [RenewalButtonYearlySetting]               INT             NULL,
    [EnableSubscriptionCancelButton]           BIT             CONSTRAINT [df_EnableSubscriptionCancelButton] DEFAULT ((0)) NOT NULL,
    [SubscriptionCancellationButtonLabel]      NVARCHAR (100)  NULL,
    [SubscriptionCancellationReversalOptionId] INT             CONSTRAINT [df_SubscriptionCancellationReversalOptionId] DEFAULT ((1)) NOT NULL,
    [SubscriptionCancellationWarningMessage]   NVARCHAR (1000) NULL,
    [TerminationButtonOptionId]                INT             CONSTRAINT [df_TerminationButtonOptionId] DEFAULT ((1)) NOT NULL,
    [AdditionalSignUpButtonLabel]              NVARCHAR (100)  NOT NULL,
    [DraftInvoiceBlockingSignUpMessage]        NVARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_HostedPageManagedSectionSubscription] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedSectionSubscription_HostedPageManagedSelfServicePortal] FOREIGN KEY ([Id]) REFERENCES [dbo].[HostedPageManagedSelfServicePortal] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionSubscription_InclusionManagementId] FOREIGN KEY ([InclusionManagementId]) REFERENCES [Lookup].[HostedPageInclusionManagement] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionSubscription_QuantityManagementId] FOREIGN KEY ([QuantityManagementId]) REFERENCES [Lookup].[HostedPageQuantityManagement] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionSubscription_SubscriptionCancellationReversalOptions] FOREIGN KEY ([SubscriptionCancellationReversalOptionId]) REFERENCES [Lookup].[SubscriptionCancellationReversalOptions] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionSubscription_TerminationButtonOptionId] FOREIGN KEY ([TerminationButtonOptionId]) REFERENCES [Lookup].[TerminationButtonOption] ([Id])
);


GO

