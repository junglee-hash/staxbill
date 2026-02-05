CREATE TABLE [dbo].[AccountSageIntacctConfiguration] (
    [Id]                                       BIGINT         NOT NULL,
    [StatusId]                                 TINYINT        NOT NULL,
    [CompanyID]                                VARCHAR (120)  NOT NULL,
    [UserID]                                   VARCHAR (120)  NOT NULL,
    [UserPassword]                             NVARCHAR (256) NOT NULL,
    [SaltPassword]                             NVARCHAR (256) NOT NULL,
    [ActivationTimestamp]                      DATETIME       NULL,
    [CreatedTimestamp]                         DATETIME       NOT NULL,
    [ModifiedTimestamp]                        DATETIME       NOT NULL,
    [DeferredRevenueAccountId]                 VARCHAR (120)  NULL,
    [EarnedRevenueAccountId]                   VARCHAR (120)  NULL,
    [DeferredDiscountAccountId]                VARCHAR (120)  NULL,
    [DiscountAccountId]                        VARCHAR (120)  NULL,
    [TaxesPayableAccountId]                    VARCHAR (120)  NULL,
    [CashAccountId]                            VARCHAR (120)  NULL,
    [CreditAccountId]                          VARCHAR (120)  NULL,
    [WriteOffAccountId]                        VARCHAR (120)  NULL,
    [SageIntacctEntityId]                      VARCHAR (120)  CONSTRAINT [DF_SageIntacctEntityId] DEFAULT ('100') NOT NULL,
    [SageIntacctLatchTypeId]                   TINYINT        CONSTRAINT [DF_SageIntacctLatchTypeId] DEFAULT ((1)) NOT NULL,
    [DisplayNameCompany]                       BIT            CONSTRAINT [DF_DisplayNameCompany_False] DEFAULT ((0)) NOT NULL,
    [DisplayNameFirstandLast]                  BIT            CONSTRAINT [DF_DisplayNameFirstandLast_False] DEFAULT ((0)) NOT NULL,
    [DisplayNameCustomerId]                    BIT            CONSTRAINT [DF_DisplayNameCustomerId_False] DEFAULT ((0)) NOT NULL,
    [LatchCustomerBillingAddressToSageIntacct] BIT            CONSTRAINT [DF_LatchCustomerBillingAddressToSageIntacct_False] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountSageIntacctConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_AccountSageIntacctConfiguration_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountSageIntacctConfiguration_SageIntacctLatchType] FOREIGN KEY ([SageIntacctLatchTypeId]) REFERENCES [Lookup].[SageIntacctLatchType] ([Id]),
    CONSTRAINT [FK_AccountSageIntacctConfiguration_SageIntacctStatus] FOREIGN KEY ([StatusId]) REFERENCES [Lookup].[SageIntacctStatus] ([Id])
);


GO

