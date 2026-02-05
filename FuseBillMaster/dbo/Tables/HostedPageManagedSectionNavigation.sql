CREATE TABLE [dbo].[HostedPageManagedSectionNavigation] (
    [Id]                         BIGINT        NOT NULL,
    [ShowHome]                   BIT           NOT NULL,
    [ShowSubscriptions]          BIT           NOT NULL,
    [ShowInvoices]               BIT           NOT NULL,
    [ShowStatements]             BIT           NOT NULL,
    [ShowPaymentMethods]         BIT           NOT NULL,
    [ShowProfile]                BIT           NOT NULL,
    [ShowLogout]                 BIT           NOT NULL,
    [ShowBreadcrumbs]            BIT           NOT NULL,
    [MigrationsGroupByFrequency] BIT           CONSTRAINT [DF_HostedPageManagedSectionNavigation_MigrationsGroupByFrequency] DEFAULT ((0)) NOT NULL,
    [DisplayUsername]            BIT           CONSTRAINT [DF_DisplayUsername] DEFAULT ((1)) NOT NULL,
    [DisplayCompanyName]         BIT           CONSTRAINT [DF_DisplayCompanyName] DEFAULT ((0)) NOT NULL,
    [DisplayFirstName]           BIT           CONSTRAINT [DF_DisplayFirstName] DEFAULT ((0)) NOT NULL,
    [DisplayLastName]            BIT           CONSTRAINT [DF_DisplayLastName] DEFAULT ((0)) NOT NULL,
    [DisplayCustomerReference]   BIT           CONSTRAINT [DF_DisplayCustomerReference] DEFAULT ((0)) NOT NULL,
    [DisplayCustomerId]          BIT           CONSTRAINT [DF_DisplayCustomerId] DEFAULT ((0)) NOT NULL,
    [MigrationsCoupon]           BIT           CONSTRAINT [DF_MigrationsCoupon] DEFAULT ((0)) NOT NULL,
    [ShowPurchases]              BIT           CONSTRAINT [DF_ShowPurchases] DEFAULT ((0)) NOT NULL,
    [ShowHomeLabel]              NVARCHAR (50) CONSTRAINT [DF_ShowHomeLabel] DEFAULT ('Home') NOT NULL,
    [ShowSubscriptionsLabel]     NVARCHAR (50) CONSTRAINT [DF_ShowSubscriptionsLabel] DEFAULT ('Subscriptions') NOT NULL,
    [ShowInvoicesLabel]          NVARCHAR (50) CONSTRAINT [DF_ShowInvoicesLabel] DEFAULT ('Invoices') NOT NULL,
    [ShowStatementsLabel]        NVARCHAR (50) CONSTRAINT [DF_ShowStatementsLabel] DEFAULT ('Statements') NOT NULL,
    [ShowPaymentMethodsLabel]    NVARCHAR (50) CONSTRAINT [DF_ShowPaymentMethodsLabel] DEFAULT ('Payment Methods') NOT NULL,
    [ShowProfileLabel]           NVARCHAR (50) CONSTRAINT [DF_ShowProfileLabel] DEFAULT ('Profile') NOT NULL,
    [ShowLogoutLabel]            NVARCHAR (50) CONSTRAINT [DF_ShowLogoutLabel] DEFAULT ('Logout/Exit') NOT NULL,
    [ShowPurchasesLabel]         NVARCHAR (50) CONSTRAINT [DF_ShowPurchasesLabel] DEFAULT ('Purchases') NOT NULL,
    CONSTRAINT [PK_HostedPageManagedSectionNavigation] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedSectionNavigation_HostedPageManagedSelfServicePortal] FOREIGN KEY ([Id]) REFERENCES [dbo].[HostedPageManagedSelfServicePortal] ([Id])
);


GO

