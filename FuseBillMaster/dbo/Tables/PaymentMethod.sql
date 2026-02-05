CREATE TABLE [dbo].[PaymentMethod] (
    [Id]                                BIGINT          IDENTITY (1, 1) NOT NULL,
    [CustomerId]                        BIGINT          NOT NULL,
    [FirstName]                         NVARCHAR (50)   NOT NULL,
    [LastName]                          NVARCHAR (50)   NOT NULL,
    [Address1]                          NVARCHAR (255)  NULL,
    [Address2]                          NVARCHAR (255)  NULL,
    [City]                              NVARCHAR (50)   NULL,
    [StateId]                           BIGINT          NULL,
    [CountryId]                         BIGINT          NULL,
    [PostalZip]                         NVARCHAR (10)   NULL,
    [Token]                             NVARCHAR (1000) NOT NULL,
    [PaymentMethodStatusId]             INT             NOT NULL,
    [AccountType]                       VARCHAR (50)    NOT NULL,
    [PaymentMethodTypeId]               INT             NULL,
    [ExternalCustomerId]                NVARCHAR (1000) NULL,
    [ExternalCardId]                    NVARCHAR (1000) NULL,
    [StoredInFusebillVault]             BIT             NOT NULL,
    [ModifiedTimestamp]                 DATETIME        NOT NULL,
    [Email]                             VARCHAR (255)   NULL,
    [OriginalPaymentMethodId]           BIGINT          NULL,
    [CreatedTimestamp]                  DATETIME        NOT NULL,
    [BusinessTaxId]                     VARCHAR (30)    NULL,
    [StoredInStax]                      BIT             CONSTRAINT [DF_PaymentMethod_StoredInStax] DEFAULT ((0)) NOT NULL,
    [Sharing]                           BIT             DEFAULT (NULL) NULL,
    [RepeatFailureCount]                INT             CONSTRAINT [DF_RepeatFailureCount] DEFAULT ((0)) NOT NULL,
    [HasMadePayment]                    BIT             NOT NULL,
    [PaymentMethodStatusDisabledTypeId] INT             NULL,
    [PaymentMethodNickname]             VARCHAR (50)    NULL,
    [PermittedForSingleUse]             BIT             CONSTRAINT [DF_PermittedForSingleUse] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_PaymentMethod] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PaymentMethod_Country] FOREIGN KEY ([CountryId]) REFERENCES [Lookup].[Country] ([Id]),
    CONSTRAINT [FK_PaymentMethod_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_PaymentMethod_OriginalPaymentMethodId] FOREIGN KEY ([OriginalPaymentMethodId]) REFERENCES [dbo].[PaymentMethod] ([Id]),
    CONSTRAINT [FK_PaymentMethod_PaymentMethodStatus] FOREIGN KEY ([PaymentMethodStatusId]) REFERENCES [Lookup].[PaymentMethodStatus] ([Id]),
    CONSTRAINT [FK_PaymentMethod_PaymentMethodStatusDisabledType] FOREIGN KEY ([PaymentMethodStatusDisabledTypeId]) REFERENCES [Lookup].[PaymentMethodStatusDisabledType] ([Id]),
    CONSTRAINT [FK_PaymentMethod_PaymentMethodType] FOREIGN KEY ([PaymentMethodTypeId]) REFERENCES [Lookup].[PaymentMethodType] ([Id]),
    CONSTRAINT [FK_PaymentMethod_State] FOREIGN KEY ([StateId]) REFERENCES [Lookup].[State] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_PaymentMethod_PaymentMethodTypeId]
    ON [dbo].[PaymentMethod]([PaymentMethodTypeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentMethod_CustomerId]
    ON [dbo].[PaymentMethod]([CustomerId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentMethod_StateId]
    ON [dbo].[PaymentMethod]([StateId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentMethod_CountryId]
    ON [dbo].[PaymentMethod]([CountryId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_PaymentMethod_PaymentMethodStatusId]
    ON [dbo].[PaymentMethod]([PaymentMethodStatusId] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 100);


GO

