CREATE TABLE [dbo].[InvoiceCustomerAdditional] (
    [Id]                         BIGINT          IDENTITY (1, 1) NOT NULL,
    [CustomerId]                 BIGINT          NOT NULL,
    [InvoiceId]                  BIGINT          NOT NULL,
    [FirstName]                  NVARCHAR (50)   NULL,
    [MiddleName]                 NVARCHAR (50)   NULL,
    [LastName]                   NVARCHAR (50)   NULL,
    [Suffix]                     NVARCHAR (50)   NULL,
    [PrimaryEmail]               VARCHAR (255)   NULL,
    [PrimaryPhone]               VARCHAR (50)    NULL,
    [SecondaryEmail]             VARCHAR (255)   NULL,
    [SecondaryPhone]             VARCHAR (50)    NULL,
    [TitleId]                    INT             NULL,
    [Reference]                  NVARCHAR (255)  NULL,
    [CreatedTimestamp]           DATETIME        NOT NULL,
    [ModifiedTimestamp]          DATETIME        NOT NULL,
    [EffectiveTimestamp]         DATETIME        NOT NULL,
    [ContactName]                NVARCHAR (250)  NULL,
    [ShippingInstructions]       NVARCHAR (1000) NULL,
    [Title]                      NVARCHAR (20)   NULL,
    [CurrencyId]                 BIGINT          NOT NULL,
    [CompanyName]                NVARCHAR (255)  NULL,
    [AvalaraUsageType]           VARCHAR (4)     NULL,
    [VATIdentificationNumber]    NVARCHAR (25)   NULL,
    [TaxExemptCode]              NVARCHAR (255)  NULL,
    [UseCustomerBillingSettings] BIT             CONSTRAINT [DF_InvoiceCustomerAdditional_UseCustomerBillingSettings] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_InvoiceCustomerAdditional] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_InvoiceCustomerAdditional_Currency] FOREIGN KEY ([CurrencyId]) REFERENCES [Lookup].[Currency] ([Id]),
    CONSTRAINT [FK_InvoiceCustomerAdditional_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_InvoiceCustomerAdditional_InvoiceId] FOREIGN KEY ([InvoiceId]) REFERENCES [dbo].[Invoice] ([Id]),
    CONSTRAINT [FK_InvoiceCustomerAdditional_Title] FOREIGN KEY ([TitleId]) REFERENCES [Lookup].[Title] ([Id])
);


GO

