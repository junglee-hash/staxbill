CREATE TABLE [dbo].[AccountBillingPreference] (
    [Id]                                  BIGINT          NOT NULL,
    [AutoPostDraftInvoice]                BIT             NOT NULL,
    [AccountGracePeriod]                  INT             CONSTRAINT [DF_AccountBillingPreference_AccountGracePeriod] DEFAULT ((0)) NULL,
    [DefaultTermId]                       INT             NOT NULL,
    [DefaultAutoCollect]                  BIT             NOT NULL,
    [CustomerAcquisitionCost]             DECIMAL (18, 2) CONSTRAINT [DF_AccountBillingPreference_CustomerAcquisitionCost] DEFAULT ((0)) NOT NULL,
    [ShowZeroDollarCharges]               BIT             NOT NULL,
    [DefaultCustomerServiceStartOptionId] INT             NOT NULL,
    [RechargeTypeId]                      INT             NULL,
    [RechargeThresholdAmount]             DECIMAL (18, 2) NULL,
    [RechargeTargetAmount]                DECIMAL (18, 2) NULL,
    [StatusOnThreshold]                   BIT             NULL,
    [EarnInPreviousPeriod]                BIT             DEFAULT ((0)) NOT NULL,
    [ModifiedTimestamp]                   DATETIME        NOT NULL,
    [AccountAutoCancel]                   INT             NULL,
    [AccountCancelOptionId]               INT             CONSTRAINT [DF_AccountBillingPreference_AccountCancelOptionId] DEFAULT ((1)) NULL,
    [PostReadyChargesOnRenew]             BIT             NOT NULL,
    [AutoCollectSettingTypeId]            INT             NULL,
    [AllowTrackedItemReferenceReuse]      BIT             DEFAULT ((0)) NOT NULL,
    [AutoSuspendEnabled]                  BIT             CONSTRAINT [DF_AutoSuspendEnabled] DEFAULT ((1)) NOT NULL,
    [CreditCardFailureLimit]              INT             NULL,
    [AchFailureLimit]                     INT             NULL,
    [AutoCancelTypeId]                    INT             CONSTRAINT [DF_AccountBillingPreference_AutoCancelTypeId] DEFAULT ((1)) NOT NULL,
    [AutoAllocateBalanceOnDeposit]        BIT             CONSTRAINT [DF_AutoAllocateBalanceOnDeposit] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_BillingPreference] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountBillingPreference_AutoCollectSettingType] FOREIGN KEY ([AutoCollectSettingTypeId]) REFERENCES [Lookup].[AutoCollectSettingType] ([Id]),
    CONSTRAINT [FK_AccountBillingPreference_RechargeType] FOREIGN KEY ([RechargeTypeId]) REFERENCES [Lookup].[RechargeType] ([Id]),
    CONSTRAINT [FK_BillingPreference_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_BillingPreference_AccountCancelOptionId] FOREIGN KEY ([AccountCancelOptionId]) REFERENCES [Lookup].[SubscriptionCancellationReversalOptions] ([Id]),
    CONSTRAINT [FK_BillingPreference_AutoCancelTypeId] FOREIGN KEY ([AutoCancelTypeId]) REFERENCES [Lookup].[AutoCancelType] ([Id]),
    CONSTRAINT [FK_BillingPreference_CustomerServiceStartOption] FOREIGN KEY ([DefaultCustomerServiceStartOptionId]) REFERENCES [Lookup].[CustomerServiceStartOption] ([Id]),
    CONSTRAINT [FK_BillingPreference_Term] FOREIGN KEY ([DefaultTermId]) REFERENCES [Lookup].[Term] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountBillingPreference_DefaultCustomerServiceStartOptionId]
    ON [dbo].[AccountBillingPreference]([DefaultCustomerServiceStartOptionId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountBillingPreference_RechargeTypeId]
    ON [dbo].[AccountBillingPreference]([RechargeTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_BillingPreference_DefaultTermId]
    ON [dbo].[AccountBillingPreference]([DefaultTermId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

