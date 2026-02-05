CREATE TABLE [dbo].[AccountFeatureConfiguration] (
    [Id]                                       BIGINT        NOT NULL,
    [CreatedTimestamp]                         DATETIME      NOT NULL,
    [ModifiedTimestamp]                        DATETIME      NOT NULL,
    [SalesforceEnabled]                        BIT           NOT NULL,
    [SalesforceSandboxMode]                    BIT           NOT NULL,
    [NetsuiteEnabled]                          BIT           CONSTRAINT [DF_AccountFeatureConfiguration_NetsuiteEnabled] DEFAULT ((0)) NOT NULL,
    [AvalaraOrganizationCode]                  VARCHAR (255) NULL,
    [TaxOptionId]                              INT           NOT NULL,
    [PaypalEnabled]                            BIT           NOT NULL,
    [WebhooksEnabled]                          BIT           DEFAULT ((0)) NOT NULL,
    [ProductImportEnabled]                     BIT           DEFAULT ((0)) NOT NULL,
    [ProjectedInvoiceEnabled]                  BIT           DEFAULT ((0)) NOT NULL,
    [MrrDisplayTypeId]                         INT           CONSTRAINT [DF_AccountFeatureConfiguration_MrrDisplayTypeId] DEFAULT ((1)) NOT NULL,
    [CustomerHierarchy]                        BIT           DEFAULT ((0)) NOT NULL,
    [QuickBooksEnabled]                        BIT           DEFAULT ((0)) NOT NULL,
    [InvoiceInAdvance]                         BIT           DEFAULT ((0)) NOT NULL,
    [PreventCreditCardValidation]              BIT           DEFAULT ((0)) NOT NULL,
    [LegacyTransparentRedirect]                BIT           DEFAULT ((1)) NOT NULL,
    [SalesforceCatalogSync]                    BIT           DEFAULT ((0)) NOT NULL,
    [BulkImportEnabled]                        BIT           DEFAULT ((1)) NOT NULL,
    [QuickBooksSandboxMode]                    BIT           DEFAULT ((0)) NOT NULL,
    [HubSpotConfigured]                        BIT           CONSTRAINT [df_AccountFeatureConfiguration_HubSpotConfigured] DEFAULT ((0)) NOT NULL,
    [HubSpotId]                                BIGINT        NULL,
    [SalesforceBulkSyncEnabled]                BIT           CONSTRAINT [DF_AccountFeatureConfiguration_SalesforceBulkSyncEnabled] DEFAULT ((0)) NOT NULL,
    [FormulaPricingEnabled]                    BIT           DEFAULT ((0)) NOT NULL,
    [EarningRecordPerMonth]                    BIT           CONSTRAINT [DF_EarningRecordPerMonth] DEFAULT ((0)) NOT NULL,
    [TextMessagingEnabled]                     BIT           CONSTRAINT [DF_AccountFeatureConfiguration_TextMessagingEnabled] DEFAULT ((0)) NOT NULL,
    [TwilioSid]                                VARCHAR (255) NULL,
    [CustomerConcurrencyLocking]               BIT           CONSTRAINT [DF_AccountFeatureConfiguration_CustomerConcurrencyLocking] DEFAULT ((1)) NOT NULL,
    [DiagnosticLogging]                        BIT           CONSTRAINT [DF_AccountFeatureConfiguration_DiagnosticLogging] DEFAULT ((0)) NOT NULL,
    [LiquidPaymentsEnabled]                    BIT           CONSTRAINT [DF_AccountFeatureConfiguration_LiquidPaymentsEnabled] DEFAULT ((0)) NOT NULL,
    [CustomReportApiSchedulingEnabled]         BIT           CONSTRAINT [DF_CustomReportApiSchedulingEnabled] DEFAULT ((0)) NOT NULL,
    [WriteOffApi]                              BIT           CONSTRAINT [DF_AccountFeatureConfiguration_WriteOffApi] DEFAULT ((0)) NOT NULL,
    [CustomerHierarchyRollup]                  BIT           CONSTRAINT [DF_CustomerHierarchyRollup] DEFAULT ((0)) NOT NULL,
    [DigitalRiverEnabled]                      BIT           CONSTRAINT [DF_AccountFeatureConfiguration_DigitalRiverEnabled] DEFAULT ((0)) NOT NULL,
    [CalculateTaxesOnDraftInvoices]            BIT           CONSTRAINT [DF_CalculateTaxesOnDraftInvoices] DEFAULT ((1)) NOT NULL,
    [PlansEndpointAppLocking]                  BIT           CONSTRAINT [DF_PlansEndpointAppLocking] DEFAULT ((0)) NOT NULL,
    [KeepReadyDraftChargesOnSubCancellation]   BIT           CONSTRAINT [DF_KeepReadyDraftChargesOnSubCancellation] DEFAULT ((0)) NOT NULL,
    [StaxGatewayMigration]                     BIT           CONSTRAINT [DF_AccountFeatureConfiguration_StaxGatewayMigration] DEFAULT ((0)) NOT NULL,
    [GenerateProjectedInvoicesDelay]           INT           CONSTRAINT [DF_GenerateProjectedInvoicesDelay] DEFAULT ((5)) NOT NULL,
    [MilestoneEarningEnabled]                  BIT           CONSTRAINT [DF_MilestoneEarningEnabled] DEFAULT ((0)) NOT NULL,
    [PaymentMethodSharing]                     BIT           NOT NULL,
    [StaxGatewayFeeRecording]                  BIT           CONSTRAINT [DF_AccountFeatureConfiguration_StaxGatewayFeeRecording] DEFAULT ((1)) NOT NULL,
    [ShowCustomerFinancialsInCustomerOverview] BIT           CONSTRAINT [DF_ShowCustomerFinancialsInCustomerOverview] DEFAULT ((1)) NOT NULL,
    [CustomerGridDisplayOptionId]              INT           CONSTRAINT [DF_DefaultCustomerGridDisplayOption] DEFAULT ((1)) NOT NULL,
    [IsSurcharging]                            BIT           CONSTRAINT [DF_IsSurcharging] DEFAULT ((0)) NOT NULL,
    [CustomerGridNameDisplayOptionId]          INT           DEFAULT ((3)) NOT NULL,
    [Idempotency]                              BIT           CONSTRAINT [DF_Idempotency] DEFAULT ((0)) NOT NULL,
    [SurchargingPolicy]                        NVARCHAR (50) NULL,
    [PaymentMethodDisable]                     BIT           CONSTRAINT [DF_PaymentMethodDisable] DEFAULT ((0)) NOT NULL,
    [UseStaxbillJs]                            BIT           CONSTRAINT [DF_UseStaxbillJs] DEFAULT ((1)) NOT NULL,
    [UseGoogleRecaptcha]                       BIT           CONSTRAINT [DF_UseGoogleRecaptcha] DEFAULT ((1)) NOT NULL,
    [UseGooglePay]                             BIT           CONSTRAINT [DF_UseGooglePay] DEFAULT ((0)) NOT NULL,
    [GatewayGridView]                          BIT           CONSTRAINT [DF_GatewayGridView] DEFAULT ((0)) NOT NULL,
    [CustomerImportApi]                        BIT           CONSTRAINT [DF_CustomerImportApi] DEFAULT ((0)) NOT NULL,
    [PricebooksEnabled]                        BIT           CONSTRAINT [DF_PricebooksEnabled] DEFAULT ((0)) NOT NULL,
    [ArActivitiesFromDW]                       BIT           CONSTRAINT [DF_ArActivitiesFromDW] DEFAULT ((0)) NOT NULL,
    [SspThemesEnabled]                         BIT           CONSTRAINT [DF_SspThemesEnabled] DEFAULT ((0)) NOT NULL,
    [ShowFirstSix]                             BIT           CONSTRAINT [DF_ShowFirstSix] DEFAULT ((0)) NOT NULL,
    [ShowWeeklyBilling]                        BIT           CONSTRAINT [DF_ShowWeeklyBilling] DEFAULT ((0)) NOT NULL,
    [ShowCustomerGridEmail]                    BIT           CONSTRAINT [DF_ShowCustomerGridEmail] DEFAULT ((0)) NOT NULL,
    [RecaptchaValidation]                      BIT           CONSTRAINT [DF_RecaptchaValidation] DEFAULT ((1)) NOT NULL,
    [ShowStaxbillJs]                           BIT           CONSTRAINT [DF_ShowStaxbillJs] DEFAULT ((1)) NOT NULL,
    [ShowTransparentRedirect]                  BIT           CONSTRAINT [DF_ShowTransparentRedirect] DEFAULT ((0)) NOT NULL,
    [SageIntacctEnabled]                       BIT           CONSTRAINT [DF_SageIntacctEnabled_False] DEFAULT ((0)) NOT NULL,
    [UseAvalaraBatchEndpoint]                  BIT           CONSTRAINT [DF_UseAvalaraBatchEndpoint] DEFAULT ((0)) NOT NULL,
    [GatewayApi]                               BIT           CONSTRAINT [DF_GatewayApi] DEFAULT ((0)) NOT NULL,
    [CurrentMrrEnabled]                        BIT           CONSTRAINT [DF_CurrentMrrEnabled] DEFAULT ((1)) NOT NULL,
    [MfaEnabled]                               BIT           CONSTRAINT [DF_MfaEnabled] DEFAULT ((0)) NOT NULL,
    [UseNewPdfGeneration]                      BIT           CONSTRAINT [DF_UseNewPdfGeneration] DEFAULT ((0)) NOT NULL,
    [Is3DSecureAuthEnabled]                    BIT           CONSTRAINT [DF_Is3DSecureAuthEnabled] DEFAULT ((0)) NOT NULL,
    [CacheGetFullAccount]                      BIT           CONSTRAINT [DF_CacheGetFullAccount] DEFAULT ((0)) NOT NULL,
    [UseAwsRouter]                             BIT           CONSTRAINT [DF_UseAwsRouter] DEFAULT ((0)) NOT NULL,
    [TestSubscriptionPerformance]              BIT           CONSTRAINT [DF_TestSubscriptionPerformance] DEFAULT ((0)) NOT NULL,
    [TestInvoicePerformance]                   BIT           CONSTRAINT [DF_TestInvoicePerformance] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountFeatureConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AccountFeatureConfiguration_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountFeatureConfiguration_CustomerGridDisplayOption] FOREIGN KEY ([CustomerGridDisplayOptionId]) REFERENCES [Lookup].[CustomerGridDisplayOption] ([Id]),
    CONSTRAINT [FK_AccountFeatureConfiguration_CustomerGridNameDisplayOption] FOREIGN KEY ([CustomerGridNameDisplayOptionId]) REFERENCES [Lookup].[CustomerGridNameDisplayOption] ([Id]),
    CONSTRAINT [FK_AccountFeatureConfiguration_MrrDisplayType] FOREIGN KEY ([MrrDisplayTypeId]) REFERENCES [Lookup].[MrrDisplayType] ([Id]),
    CONSTRAINT [FK_AccountFeatureConfiguration_TaxOption] FOREIGN KEY ([TaxOptionId]) REFERENCES [Lookup].[TaxOption] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_AccountFeatureConfiguration_TextMessagingEnabled_TwilioSid]
    ON [dbo].[AccountFeatureConfiguration]([TextMessagingEnabled] ASC, [TwilioSid] ASC) WITH (FILLFACTOR = 100);


GO

CREATE NONCLUSTERED INDEX [FKIX_AccountFeatureConfiguration_TaxOptionId]
    ON [dbo].[AccountFeatureConfiguration]([TaxOptionId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

