CREATE TABLE [dbo].[HubspotClerkAccess] (
    [Id]                           BIGINT NOT NULL,
    [AllowCustomerEdit]            BIT    DEFAULT ((1)) NOT NULL,
    [AllowCustomerPaymentMethod]   BIT    DEFAULT ((1)) NOT NULL,
    [AllowDealActivate]            BIT    DEFAULT ((1)) NOT NULL,
    [AllowCustomerManageCredit]    BIT    DEFAULT ((1)) NOT NULL,
    [AllowCustomerMakePayment]     BIT    DEFAULT ((1)) NOT NULL,
    [AllowCustomerBillingSettings] BIT    DEFAULT ((1)) NOT NULL,
    [AllowCustomerNoteManagement]  BIT    DEFAULT ((1)) NOT NULL,
    [AllowHistoricalPayments]      BIT    DEFAULT ((1)) NOT NULL,
    [AllowSubscriptionEdit]        BIT    DEFAULT ((1)) NOT NULL,
    [AllowSubscriptionProductEdit] BIT    DEFAULT ((1)) NOT NULL,
    [AllowSubscriptionMigration]   BIT    DEFAULT ((1)) NOT NULL,
    [AllowSubscriptionCancel]      BIT    DEFAULT ((1)) NOT NULL,
    [AllowInvoiceView]             BIT    DEFAULT ((1)) NOT NULL,
    [AllowInvoiceVoid]             BIT    DEFAULT ((1)) NOT NULL,
    [AllowInvoiceVoidAndRefund]    BIT    DEFAULT ((1)) NOT NULL,
    [AllowEmailCommunication]      BIT    CONSTRAINT [DF_AllowEmailCommunication_True] DEFAULT ((1)) NOT NULL,
    [AllowAuditLog]                BIT    CONSTRAINT [DF_AllowAuditLog_True] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_HubspotClerkAccess] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_HubspotUser_AccountHubSpotConfiguration] FOREIGN KEY ([Id]) REFERENCES [dbo].[AccountHubSpotConfiguration] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_HubspotClerkAccess_AccountHubSpotConfiguration]
    ON [dbo].[HubspotClerkAccess]([Id] ASC);


GO

