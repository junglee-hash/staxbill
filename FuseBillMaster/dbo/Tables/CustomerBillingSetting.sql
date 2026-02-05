CREATE TABLE [dbo].[CustomerBillingSetting] (
    [Id]                           BIGINT          NOT NULL,
    [CreatedTimestamp]             DATETIME        NOT NULL,
    [ModifiedTimestamp]            DATETIME        NOT NULL,
    [InvoiceDay]                   INT             NULL,
    [TermId]                       INT             NOT NULL,
    [IntervalId]                   INT             NOT NULL,
    [AutoCollect]                  BIT             CONSTRAINT [DF_CustomerBillingSetting_AutoCollect] DEFAULT ((0)) NULL,
    [AutoPostDraftInvoice]         BIT             NULL,
    [CustomerGracePeriod]          INT             NULL,
    [GracePeriodExtension]         INT             NULL,
    [StandingPo]                   VARCHAR (255)   NULL,
    [AcquisitionCost]              DECIMAL (18, 2) CONSTRAINT [DF_CustomerBillingSetting_CustomerAcquisitionCost] DEFAULT ((0)) NOT NULL,
    [ShowZeroDollarCharges]        BIT             NULL,
    [TaxExempt]                    BIT             CONSTRAINT [DF_CustomerBillingSetting_TaxExempt] DEFAULT ((0)) NOT NULL,
    [TaxExemptCode]                NVARCHAR (255)  NULL,
    [CustomerServiceStartOptionId] INT             NULL,
    [RechargeTypeId]               INT             NULL,
    [RechargeThresholdAmount]      DECIMAL (18, 2) NULL,
    [RechargeTargetAmount]         DECIMAL (18, 2) NULL,
    [StatusOnThreshold]            BIT             NULL,
    [AvalaraUsageType]             VARCHAR (4)     NULL,
    [VATIdentificationNumber]      NVARCHAR (25)   NULL,
    [UseCustomerBillingAddress]    BIT             NULL,
    [DefaultPaymentMethodId]       BIGINT          NULL,
    [CustomerAutoCancel]           INT             NULL,
    [CustomerCancelOptionId]       INT             NULL,
    [PostReadyChargesOnRenew]      BIT             NULL,
    [DunningExempt]                BIT             CONSTRAINT [DF_CustomerBillingSetting_DunningExempt] DEFAULT ((0)) NOT NULL,
    [HierarchySuspendOptionId]     INT             NULL,
    [AutoCollectSettingTypeId]     INT             NULL,
    [AutoAllocateBalanceOnDeposit] BIT             NULL,
    CONSTRAINT [PK_CustomerBillingSetting] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerBillingSetting_AutoCollectSettingType] FOREIGN KEY ([AutoCollectSettingTypeId]) REFERENCES [Lookup].[AutoCollectSettingType] ([Id]),
    CONSTRAINT [FK_CustomerBillingSetting_Customer] FOREIGN KEY ([Id]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_CustomerBillingSetting_CustomerCancelOptionId] FOREIGN KEY ([CustomerCancelOptionId]) REFERENCES [Lookup].[SubscriptionCancellationReversalOptions] ([Id]),
    CONSTRAINT [FK_CustomerBillingSetting_CustomerServiceStartOption] FOREIGN KEY ([CustomerServiceStartOptionId]) REFERENCES [Lookup].[CustomerServiceStartOption] ([Id]),
    CONSTRAINT [FK_CustomerBillingSetting_HierarchySuspendOption] FOREIGN KEY ([HierarchySuspendOptionId]) REFERENCES [Lookup].[HierarchySuspendOptions] ([Id]),
    CONSTRAINT [FK_CustomerBillingSetting_Interval] FOREIGN KEY ([IntervalId]) REFERENCES [Lookup].[Interval] ([Id]),
    CONSTRAINT [FK_CustomerBillingSetting_PaymentMethod] FOREIGN KEY ([DefaultPaymentMethodId]) REFERENCES [dbo].[PaymentMethod] ([Id]),
    CONSTRAINT [FK_CustomerBillingSetting_Term1] FOREIGN KEY ([TermId]) REFERENCES [Lookup].[Term] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_CustomerBillingSetting_CustomerServiceStartOptionId]
    ON [dbo].[CustomerBillingSetting]([CustomerServiceStartOptionId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerBillingSetting_DefaultPaymentMethodId]
    ON [dbo].[CustomerBillingSetting]([DefaultPaymentMethodId] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerBillingSetting_IntervalId]
    ON [dbo].[CustomerBillingSetting]([IntervalId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_CustomerBillingSetting_TermId]
    ON [dbo].[CustomerBillingSetting]([TermId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

