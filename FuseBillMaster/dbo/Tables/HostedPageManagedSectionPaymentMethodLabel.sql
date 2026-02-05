CREATE TABLE [dbo].[HostedPageManagedSectionPaymentMethodLabel] (
    [Id]                                   BIGINT         IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedSelfServicePortalId] BIGINT         NOT NULL,
    [PaymentMethodFieldId]                 BIGINT         NOT NULL,
    [Label]                                NVARCHAR (100) NOT NULL,
    [Visible]                              BIT            NOT NULL,
    [Required]                             BIT            NOT NULL,
    [DefaultValue]                         NVARCHAR (255) NULL,
    CONSTRAINT [PK_HostedPageManagedSectionPaymentMethodLabel] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_HostedPageManagedSectionPaymentMethodLabel_HostedPageManagedSelfServicePortal] FOREIGN KEY ([HostedPageManagedSelfServicePortalId]) REFERENCES [dbo].[HostedPageManagedSelfServicePortal] ([Id]),
    CONSTRAINT [FK_HostedPageManagedSectionPaymentMethodLabel_PaymentMethodField] FOREIGN KEY ([PaymentMethodFieldId]) REFERENCES [Lookup].[PaymentMethodField] ([Id])
);


GO

