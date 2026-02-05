CREATE TABLE [dbo].[HostedPageManagedOfferingPreviewPanel] (
    [Id]                          BIGINT         NOT NULL,
    [Visible]                     BIT            NOT NULL,
    [OrderSummaryTitleLabel]      NVARCHAR (50)  NOT NULL,
    [PlanSelectLinkText]          NVARCHAR (25)  NOT NULL,
    [PlanConfigureLinkText]       NVARCHAR (25)  NOT NULL,
    [InitialChargeLabel]          NVARCHAR (50)  NOT NULL,
    [RecurringChargeLabel]        NVARCHAR (50)  NOT NULL,
    [TaxWarningLabel]             NVARCHAR (100) NOT NULL,
    [Coupon]                      BIT            NOT NULL,
    [CouponLabel]                 NVARCHAR (25)  NOT NULL,
    [CouponButtonLabel]           NVARCHAR (25)  NOT NULL,
    [CustomerSummaryTitleLabel]   NVARCHAR (50)  NOT NULL,
    [BillingAddressTitleLabel]    NVARCHAR (255) NULL,
    [ShippingAddressTitleLabel]   NVARCHAR (255) NULL,
    [CustomerInformationLinkText] NVARCHAR (25)  NOT NULL,
    [DiscountLabel]               NVARCHAR (25)  NOT NULL,
    [PaymentMethodLabel]          NVARCHAR (50)  CONSTRAINT [DF_PaymentMethodLabel] DEFAULT ('Payment') NOT NULL,
    [InvoicePreviewLabel]         NVARCHAR (50)  CONSTRAINT [DF_InvoicePreviewLabel] DEFAULT ('Invoice Preview') NOT NULL,
    CONSTRAINT [PK_HostedPageManagedOfferingPreviewPanel] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedOfferingPreviewPanel_HostedPageManagedOffering] FOREIGN KEY ([Id]) REFERENCES [dbo].[HostedPageManagedOffering] ([Id])
);


GO

