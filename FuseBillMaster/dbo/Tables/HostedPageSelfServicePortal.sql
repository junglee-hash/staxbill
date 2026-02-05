CREATE TABLE [dbo].[HostedPageSelfServicePortal] (
    [Id]                                       BIGINT          NOT NULL,
    [UnauthenticatedHeader]                    NVARCHAR (MAX)  NULL,
    [LoginLabel]                               NVARCHAR (MAX)  NULL,
    [Home]                                     NVARCHAR (MAX)  NULL,
    [EnableStatements]                         BIT             NOT NULL,
    [ErrorUrl]                                 VARCHAR (100)   NULL,
    [EnableRenewalButton]                      BIT             DEFAULT ((0)) NOT NULL,
    [RenewalButtonLabel]                       NVARCHAR (100)  NULL,
    [RenewalButtonMonthlySetting]              INT             NULL,
    [RenewalButtonYearlySetting]               INT             NULL,
    [EnableSubscriptionCancelButton]           BIT             DEFAULT ((0)) NOT NULL,
    [SubscriptionCancellationButtonLabel]      NVARCHAR (100)  NULL,
    [SubscriptionCancellationReversalOptionId] INT             NOT NULL,
    [SubscriptionCancellationWarningMessage]   NVARCHAR (1000) NULL,
    [QuantityManagementId]                     TINYINT         CONSTRAINT [df_QuantityManagementId] DEFAULT ((1)) NOT NULL,
    [InclusionManagementId]                    TINYINT         CONSTRAINT [df_InclusionManagementId] DEFAULT ((1)) NOT NULL,
    [TerminationButtonOptionId]                INT             CONSTRAINT [df_HostedPageSelfServicePortal_TerminationButtonOptionId] DEFAULT ((1)) NOT NULL,
    [ShowAutoRenewLabel]                       BIT             DEFAULT ((0)) NOT NULL,
    [AllowPaymentMethodDelete]                 BIT             DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_HostedPageSelfServicePortal_HostedPage] FOREIGN KEY ([Id]) REFERENCES [dbo].[HostedPage] ([Id]),
    CONSTRAINT [FK_HostedPageSelfServicePortal_InclusionManagementId] FOREIGN KEY ([InclusionManagementId]) REFERENCES [Lookup].[HostedPageInclusionManagement] ([Id]),
    CONSTRAINT [FK_HostedPageSelfServicePortal_QuantityManagementId] FOREIGN KEY ([QuantityManagementId]) REFERENCES [Lookup].[HostedPageQuantityManagement] ([Id]),
    CONSTRAINT [FK_HostedPageSelfServicePortal_SubscriptionCancellationReversalOptions] FOREIGN KEY ([SubscriptionCancellationReversalOptionId]) REFERENCES [Lookup].[SubscriptionCancellationReversalOptions] ([Id]),
    CONSTRAINT [FK_HostedPageSelfServicePortal_TerminationButtonOptionId] FOREIGN KEY ([TerminationButtonOptionId]) REFERENCES [Lookup].[TerminationButtonOption] ([Id])
);


GO

