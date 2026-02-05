CREATE TABLE [dbo].[HostedPageRegistration] (
    [Id]                        BIGINT         NOT NULL,
    [SuccessUrl]                VARCHAR (100)  NULL,
    [FailureUrl]                VARCHAR (100)  NULL,
    [CustomerInformation]       NVARCHAR (MAX) NULL,
    [PlanList]                  NVARCHAR (MAX) NULL,
    [PaymentMethod]             NVARCHAR (MAX) NULL,
    [InvoicePreview]            NVARCHAR (MAX) NULL,
    [AllowCoupons]              BIT            CONSTRAINT [DF_AllowCoupons] DEFAULT ((0)) NOT NULL,
    [SalesTrackingCode1Id]      BIGINT         NULL,
    [SalesTrackingCode2Id]      BIGINT         NULL,
    [SalesTrackingCode3Id]      BIGINT         NULL,
    [SalesTrackingCode4Id]      BIGINT         NULL,
    [SalesTrackingCode5Id]      BIGINT         NULL,
    [UseLegacyView]             BIT            NOT NULL,
    [ShowTermsAndConditions]    BIT            NOT NULL,
    [TermsCheckboxLabel]        VARCHAR (255)  NULL,
    [TermsLink]                 VARCHAR (255)  NULL,
    [TermsLinkText]             VARCHAR (255)  NULL,
    [ShowPlanTotals]            BIT            CONSTRAINT [DF_HostedPageRegistration_ShowPlanTotals_Default] DEFAULT ((1)) NOT NULL,
    [ShowPlanNote]              BIT            CONSTRAINT [DF_HostedPageRegistration_ShowPlanNote_Default] DEFAULT ((1)) NOT NULL,
    [PlanNoteText]              NVARCHAR (500) NULL,
    [AllowNoPaymentCapture]     BIT            CONSTRAINT [DF_HostedPageRegistration_AllowNoPaymentCapture] DEFAULT ((0)) NOT NULL,
    [NoPaymentTermId]           INT            NULL,
    [CurrencyId]                BIGINT         NULL,
    [CollectPaymentImmediately] BIT            DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_HostedPageRegistration_HostedPage] FOREIGN KEY ([Id]) REFERENCES [dbo].[HostedPage] ([Id]),
    CONSTRAINT [FK_HostedPageRegistration_NoPaymentTermId] FOREIGN KEY ([NoPaymentTermId]) REFERENCES [Lookup].[Term] ([Id]),
    CONSTRAINT [FK_HostedPageRegistration_SalesTrackingCode1] FOREIGN KEY ([SalesTrackingCode1Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_HostedPageRegistration_SalesTrackingCode2] FOREIGN KEY ([SalesTrackingCode2Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_HostedPageRegistration_SalesTrackingCode3] FOREIGN KEY ([SalesTrackingCode3Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_HostedPageRegistration_SalesTrackingCode4] FOREIGN KEY ([SalesTrackingCode4Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_HostedPageRegistration_SalesTrackingCode5] FOREIGN KEY ([SalesTrackingCode5Id]) REFERENCES [dbo].[SalesTrackingCode] ([Id]),
    CONSTRAINT [FK_HostedPageRegistrationCurrencyId_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_HostedPageRegistration_SalesTrackingCode3Id]
    ON [dbo].[HostedPageRegistration]([SalesTrackingCode3Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_HostedPageRegistration_SalesTrackingCode1Id]
    ON [dbo].[HostedPageRegistration]([SalesTrackingCode1Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_HostedPageRegistration_SalesTrackingCode4Id]
    ON [dbo].[HostedPageRegistration]([SalesTrackingCode4Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_HostedPageRegistration_SalesTrackingCode2Id]
    ON [dbo].[HostedPageRegistration]([SalesTrackingCode2Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [FKIX_HostedPageRegistration_SalesTrackingCode5Id]
    ON [dbo].[HostedPageRegistration]([SalesTrackingCode5Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

