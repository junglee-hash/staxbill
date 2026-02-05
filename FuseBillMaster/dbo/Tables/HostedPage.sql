CREATE TABLE [dbo].[HostedPage] (
    [Id]                               BIGINT         IDENTITY (1, 1) NOT NULL,
    [AccountId]                        BIGINT         NOT NULL,
    [HostedPageTypeId]                 INT            NOT NULL,
    [FriendlyName]                     NVARCHAR (255) NOT NULL,
    [HostedPageDomainId]               INT            NOT NULL,
    [Key]                              NVARCHAR (255) NOT NULL,
    [HostedPageStatusId]               INT            NOT NULL,
    [Header]                           NVARCHAR (MAX) NULL,
    [SubHeader]                        NVARCHAR (MAX) NULL,
    [Footer]                           NVARCHAR (MAX) NULL,
    [PreFooter]                        NVARCHAR (MAX) NULL,
    [CSS]                              NVARCHAR (MAX) NULL,
    [Menu]                             NVARCHAR (MAX) NULL,
    [GoogleAnalytics]                  NVARCHAR (MAX) NULL,
    [Version]                          INT            CONSTRAINT [DF_HostedPageVersion] DEFAULT ((1)) NOT NULL,
    [DefaultPaymentMethodType]         INT            CONSTRAINT [DF_HostedPage_DefaultPaymentMethodType] DEFAULT ((3)) NOT NULL,
    [EnableSingleSignOn]               BIT            CONSTRAINT [df_EnableSingleSignOn] DEFAULT ((0)) NOT NULL,
    [LandingPageUrl]                   VARCHAR (255)  NULL,
    [CollectOutstandingBalanceDefault] BIT            CONSTRAINT [df_CollectOutstandingBalanceDefault] DEFAULT ((1)) NOT NULL,
    [ParentalAccess]                   BIT            CONSTRAINT [DF_HostedPage_ParentalAccess] DEFAULT ((0)) NOT NULL,
    [ParentalInvoice]                  BIT            CONSTRAINT [DF_ParentalInvoice] DEFAULT ((0)) NOT NULL,
    [AllowChildDonation]               BIT            CONSTRAINT [DF_AllowChildDonation] DEFAULT ((0)) NOT NULL,
    [ShowGenericErrorWhenDisabled]     BIT            CONSTRAINT [DF_ShowGenericErrorWhenDisabled] DEFAULT ((0)) NOT NULL,
    [RedirectToSspV2WhenDisabled]      BIT            CONSTRAINT [DF_RedirectToSspV2WhenDisabled] DEFAULT ((0)) NOT NULL,
    [RedirectToUrlWhenDisabled]        VARCHAR (255)  NULL,
    CONSTRAINT [PK_HostPage] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_HostPage_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_HostPage_HostedPageDomain] FOREIGN KEY ([HostedPageDomainId]) REFERENCES [Lookup].[HostedPageDomain] ([Id]),
    CONSTRAINT [FK_HostPage_HostedPageStatus] FOREIGN KEY ([HostedPageStatusId]) REFERENCES [Lookup].[HostedPageStatus] ([Id]),
    CONSTRAINT [FK_HostPage_HostedPageType] FOREIGN KEY ([HostedPageTypeId]) REFERENCES [Lookup].[HostedPageType] ([Id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_HostedPageKey_Reg, HostedPageTypeId, Key]
    ON [dbo].[HostedPage]([HostedPageTypeId] ASC, [Key] ASC) WHERE ([HostedPageTypeId]=(1) AND [HostedPageStatusId]<>(3)) WITH (FILLFACTOR = 80);


GO

CREATE NONCLUSTERED INDEX [FKIX_HostedPage_AccountId]
    ON [dbo].[HostedPage]([AccountId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_HostedPageKey_Ssp, HostedPageTypeId, Key]
    ON [dbo].[HostedPage]([HostedPageTypeId] ASC, [Key] ASC) WHERE ([HostedPageTypeId]<>(1) AND [HostedPageStatusId]=(2)) WITH (FILLFACTOR = 80);


GO

CREATE NONCLUSTERED INDEX [FKIX_HostedPage_HostedPageDomainId]
    ON [dbo].[HostedPage]([HostedPageDomainId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_HostedPage_HostedPageStatusId]
    ON [dbo].[HostedPage]([HostedPageStatusId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_HostedPage_HostedPageTypeId]
    ON [dbo].[HostedPage]([HostedPageTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

