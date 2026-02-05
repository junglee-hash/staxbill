CREATE TABLE [dbo].[HostedPageManagedOffering] (
    [Id]                                   BIGINT           IDENTITY (1, 1) NOT NULL,
    [UniqueId]                             UNIQUEIDENTIFIER NOT NULL,
    [HostedPageId]                         BIGINT           NOT NULL,
    [HostedPageManagedSelfServicePortalId] BIGINT           NOT NULL,
    [FriendlyName]                         NVARCHAR (100)   NOT NULL,
    [Key]                                  VARCHAR (100)    NOT NULL,
    [TermsAndConditionsLink]               VARCHAR (255)    NOT NULL,
    [ForcePaymentMethodCapture]            BIT              NOT NULL,
    [AutoRedirect]                         BIT              NOT NULL,
    [RedirectUrl]                          NVARCHAR (255)   NULL,
    [RedirectLabel]                        NVARCHAR (50)    NULL,
    [CurrencyId]                           BIGINT           NOT NULL,
    [ThankYouPageContent]                  NVARCHAR (2000)  NULL,
    [NavigationBarVisible]                 BIT              CONSTRAINT [DF_NavigationBarVisible] DEFAULT ((0)) NOT NULL,
    [RedirectUrlForExisting]               NVARCHAR (255)   NULL,
    [AutoRedirectForExisting]              BIT              CONSTRAINT [DF_AutoRedirectForExisting] DEFAULT ((0)) NOT NULL,
    [RedirectLabelForExisting]             NVARCHAR (50)    NULL,
    [ThankYouPageContentForExisting]       NVARCHAR (2000)  NULL,
    [AllowCreditCard]                      BIT              CONSTRAINT [DF_AllowCreditCard] DEFAULT ((1)) NOT NULL,
    [ShowCreditCardIcon]                   BIT              CONSTRAINT [DF_ShowCreditCardIcon] DEFAULT ((1)) NOT NULL,
    [AllowBankAccount]                     BIT              CONSTRAINT [DF_AllowBankAccount] DEFAULT ((1)) NOT NULL,
    [ShowBankAccountIcon]                  BIT              CONSTRAINT [DF_ShowBankAccountIcon] DEFAULT ((1)) NOT NULL,
    [ShowNoPaymentMethodIcon]              BIT              CONSTRAINT [DF_ShowNoPaymentMethodIcon] DEFAULT ((1)) NOT NULL,
    [ShowFriendlyName]                     BIT              CONSTRAINT [DF_ShowFriendlyName] DEFAULT ((0)) NOT NULL,
    [HubSpotCreateContact]                 BIT              CONSTRAINT [DF_HubSpotCreateContact] DEFAULT ((0)) NOT NULL,
    [HubSpotCreateCompany]                 BIT              CONSTRAINT [DF_HubSpotCreateCompany] DEFAULT ((0)) NOT NULL,
    [RollBackFailedPayments]               BIT              CONSTRAINT [DF_RollBackFailedPayments] DEFAULT ((1)) NOT NULL,
    [CustomerIdUrlVisibleNew]              BIT              CONSTRAINT [DF_CustomerIdUrlVisibleNew] DEFAULT ((0)) NOT NULL,
    [CustomerIdUrlVisibleExisting]         BIT              CONSTRAINT [DF_CustomerIdUrlVisibleExisting] DEFAULT ((0)) NOT NULL,
    [AllowPaypal]                          BIT              CONSTRAINT [DF_AllowPaypal] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_HostedPageManagedOffering] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedOffering_HostedPage] FOREIGN KEY ([HostedPageId]) REFERENCES [dbo].[HostedPage] ([Id]),
    CONSTRAINT [FK_HostedPageManagedOffering_HostedPageManagedSelfServicePortal] FOREIGN KEY ([HostedPageManagedSelfServicePortalId]) REFERENCES [dbo].[HostedPageManagedSelfServicePortal] ([Id]),
    CONSTRAINT [FK_HostedPageManagedOfferingCurrencyId_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id]),
    CONSTRAINT [UK_HostedPageManagedOfferingKey] UNIQUE NONCLUSTERED ([Key] ASC, [HostedPageId] ASC, [HostedPageManagedSelfServicePortalId] ASC) WITH (FILLFACTOR = 100)
);


GO

CREATE NONCLUSTERED INDEX [FKIX_HostedPageManagedOffering_HostedPageId]
    ON [dbo].[HostedPageManagedOffering]([HostedPageId] ASC) WITH (FILLFACTOR = 100);


GO

