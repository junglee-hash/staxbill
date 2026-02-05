CREATE TABLE [dbo].[HostedPageManagedSectionPaymentMethod] (
    [Id]                                BIGINT        NOT NULL,
    [AllowDeleteLastPaymentMethod]      BIT           CONSTRAINT [DF_HostedPageManagedSectionPaymentMethod_AllowDeleteLastPaymentMethod] DEFAULT ((1)) NOT NULL,
    [AllowSubscriptionPaymentMethod]    BIT           CONSTRAINT [df_AllowSubscriptionPaymentMethod] DEFAULT ((0)) NOT NULL,
    [AllowAdvancedPaymentMethodSharing] BIT           CONSTRAINT [DF_AllowAdvancedPaymentMethodSharing] DEFAULT ((0)) NOT NULL,
    [SurchargingLabel]                  VARCHAR (500) CONSTRAINT [DF_SurchargingLabel] DEFAULT ('To cover the cost of credit card acceptance, we pass on a 3.5% credit card fee. This fee is not more than the cost of accepting these cards. There is no fee for debit cards.') NOT NULL,
    [AllowCreditCard]                   BIT           CONSTRAINT [DF_AllowCreditCard_SSP] DEFAULT ((1)) NOT NULL,
    [AllowBankAccount]                  BIT           CONSTRAINT [DF_AllowBankAccount_SSP] DEFAULT ((1)) NOT NULL,
    [AllowPaypal]                       BIT           CONSTRAINT [DF_AllowPaypal_SSP] DEFAULT ((1)) NOT NULL,
    [AllowGooglePay]                    BIT           CONSTRAINT [DF_AllowGooglePay_SSP] DEFAULT ((1)) NOT NULL,
    [CreditCardLabel]                   VARCHAR (50)  CONSTRAINT [DF_CreditCardLabel] DEFAULT ('Credit Card') NOT NULL,
    [AchLabel]                          VARCHAR (50)  CONSTRAINT [DF_AchLabel] DEFAULT ('Bank Account') NOT NULL,
    [CreditCardGenericIcon]             BIT           CONSTRAINT [DF_CreditCardGenericIcon] DEFAULT ((1)) NOT NULL,
    [AchGenericIcon]                    BIT           CONSTRAINT [DF_AchGenericIcon] DEFAULT ((1)) NOT NULL,
    [CvvHintLabel]                      VARCHAR (100) CONSTRAINT [DF_CvvHintLabel] DEFAULT ('(3 digits on back of card, AMEX: 4 digits on front)') NOT NULL,
    [AllowNicknamePaymentMethod]        BIT           CONSTRAINT [DF_AllowNicknamePaymentMethod] DEFAULT ((0)) NOT NULL,
    [AllowSingleUsePaymentMethod]       BIT           CONSTRAINT [DF_AllowSingleUsePaymentMethod] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_HostedPageManagedSectionPaymentMethod] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedSectionPaymentMethod_HostedPageManagedSelfServicePortal] FOREIGN KEY ([Id]) REFERENCES [dbo].[HostedPageManagedSelfServicePortal] ([Id])
);


GO

