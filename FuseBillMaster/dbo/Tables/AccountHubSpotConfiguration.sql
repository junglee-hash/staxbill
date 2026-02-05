CREATE TABLE [dbo].[AccountHubSpotConfiguration] (
    [Id]                                 BIGINT         NOT NULL,
    [IFrameAllowContactDealActivation]   BIT            CONSTRAINT [DF_IFrameAllowContactDealActivation] DEFAULT ((1)) NOT NULL,
    [IsSandbox]                          BIT            CONSTRAINT [DF_IsSandbox] DEFAULT ((1)) NOT NULL,
    [IsConnected]                        BIT            CONSTRAINT [DF_IsConnected] DEFAULT ((0)) NOT NULL,
    [IFrameEnforceDealStageForActivate]  BIT            NULL,
    [IFrameDealStageValueForActivate]    NVARCHAR (255) NULL,
    [DealUpdateTypeId]                   INT            CONSTRAINT [DF_HubSpotDealUpdateType] DEFAULT ((1)) NOT NULL,
    [IFrameAllowInvoiceVoidAndRefund]    BIT            CONSTRAINT [DF_AllowInvoiceVoidAndRefund] DEFAULT ((0)) NOT NULL,
    [IFrameAllowInvoiceVoid]             BIT            CONSTRAINT [DF_AllowInvoiceVoid_defaultvalue] DEFAULT ((0)) NOT NULL,
    [IFrameAllowSubscriptionEdit]        BIT            CONSTRAINT [DF_IFrameAllowSubscriptionEdit_False] DEFAULT ((0)) NOT NULL,
    [IFrameAllowSubscriptionProductEdit] BIT            CONSTRAINT [DF_IFrameAllowSubscriptionProductEdit_False] DEFAULT ((0)) NOT NULL,
    [IFrameAllowSubscriptionCancel]      BIT            CONSTRAINT [DF_IFrameAllowSubscriptionCancel_False] DEFAULT ((0)) NOT NULL,
    [IFrameAllowCustomerMakePayment]     BIT            CONSTRAINT [DF_IFrameAllowCustomerMakePayment_False] DEFAULT ((0)) NOT NULL,
    [IFrameAllowCustomerManageCredit]    BIT            CONSTRAINT [DF_IFrameAllowCustomerManageCredit_False] DEFAULT ((0)) NOT NULL,
    [IFrameRestrictAvailableCoupon]      BIT            CONSTRAINT [DF_IFrameRestrictAvailableCoupon_False] DEFAULT ((0)) NOT NULL,
    [IFrameAllowCustomerBillingSettings] BIT            CONSTRAINT [DF_IFrameAllowCustomerBillingSettings_False] DEFAULT ((0)) NOT NULL,
    [IFrameSubscriptionMigrationOption]  TINYINT        CONSTRAINT [DF_IFrameSubscriptionMigrationOption_Immediate] DEFAULT ((1)) NOT NULL,
    [IFrameAllowSubscriptionMigration]   BIT            CONSTRAINT [DF_IFrameAllowSubscriptionMigration_False] DEFAULT ((0)) NOT NULL,
    [IFrameAllowCustomerNoteManagement]  BIT            CONSTRAINT [DF_IFrameAllowCustomerNoteManagement_False] DEFAULT ((0)) NOT NULL,
    [IFrameAccessHistoricalPayments]     BIT            CONSTRAINT [DF_IFrameAccessHistoricalPayments_False] DEFAULT ((0)) NOT NULL,
    [IFrameAllowCustomer]                BIT            CONSTRAINT [DF_IFrameAllowCustomer_True] DEFAULT ((1)) NOT NULL,
    [IFrameAllowSubscription]            BIT            CONSTRAINT [DF_IFrameAllowSubscription_True] DEFAULT ((1)) NOT NULL,
    [IFrameAllowInvoice]                 BIT            CONSTRAINT [DF_IFrameAllowInvoice_True] DEFAULT ((1)) NOT NULL,
    [IFrameAllowPurchase]                BIT            CONSTRAINT [DF_IFrameAllowPurchase_True] DEFAULT ((1)) NOT NULL,
    [IFrameAllowCustomerEdit]            BIT            CONSTRAINT [DF_IFrameAllowCustomerEdit_True] DEFAULT ((1)) NOT NULL,
    [IFrameAllowCustomerPaymentMethod]   BIT            CONSTRAINT [DF_IFrameAllowCustomerPaymentMethod_True] DEFAULT ((1)) NOT NULL,
    [IFrameAllowRestrictHubspotUser]     BIT            CONSTRAINT [DF_IFrameAllowRestrictHubspotUser_False] DEFAULT ((0)) NOT NULL,
    [IFrameAllowInvoiceView]             BIT            CONSTRAINT [DF_IFrameAllowInvoiceView_True] DEFAULT ((1)) NOT NULL,
    [IFrameAllowAuditLog]                BIT            CONSTRAINT [DF_IFrameAllowAuditLog_False] DEFAULT ((0)) NOT NULL,
    [IFrameAllowEmailCommunication]      BIT            CONSTRAINT [DF_IFrameAllowEmailCommunication_False] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountHubSpotConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountHubSpotConfiguration_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id])
);


GO

