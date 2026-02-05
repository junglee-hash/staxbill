CREATE TABLE [dbo].[HostedPageManagedOfferingPaymentMethod] (
    [Id]                          BIGINT         IDENTITY (1, 1) NOT NULL,
    [HostedPageManagedOfferingId] BIGINT         NOT NULL,
    [PaymentMethodFieldId]        BIGINT         NOT NULL,
    [Label]                       NVARCHAR (100) NOT NULL,
    [Visible]                     BIT            NOT NULL,
    [Required]                    BIT            NOT NULL,
    [DefaultValue]                NVARCHAR (255) NULL,
    CONSTRAINT [PK_HostedPageManagedOfferingPaymentMethod] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_HostedPageManagedOfferingPaymentMethod_HostedPageManagedOffering] FOREIGN KEY ([HostedPageManagedOfferingId]) REFERENCES [dbo].[HostedPageManagedOffering] ([Id]),
    CONSTRAINT [FK_HostedPageManagedOfferingPaymentMethod_PaymentMethodField] FOREIGN KEY ([PaymentMethodFieldId]) REFERENCES [Lookup].[PaymentMethodField] ([Id])
);


GO

