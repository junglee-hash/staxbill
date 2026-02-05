CREATE TABLE [dbo].[DefaultHostedPageManagedSectionPaymentMethodLabel] (
    [Id]         BIGINT         NOT NULL,
    [FieldValue] NVARCHAR (100) NOT NULL,
    [Visible]    BIT            NOT NULL,
    [Required]   BIT            NOT NULL,
    CONSTRAINT [PK_DefaultHostedPageManagedSectionPaymentMethodLabel] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_DefaultHostedPageManagedSectionPaymentMethodLabel_PaymentMethodField] FOREIGN KEY ([Id]) REFERENCES [Lookup].[PaymentMethodField] ([Id])
);


GO

