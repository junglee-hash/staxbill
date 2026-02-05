CREATE TABLE [dbo].[BillingPeriodDefinition] (
    [Id]                   BIGINT        IDENTITY (1, 1) NOT NULL,
    [CustomerId]           BIGINT        NOT NULL,
    [IntervalId]           INT           NOT NULL,
    [NumberOfIntervals]    INT           NOT NULL,
    [InvoiceDay]           INT           NULL,
    [BillingPeriodTypeId]  INT           NOT NULL,
    [InvoiceMonth]         INT           NULL,
    [ModifiedTimestamp]    DATETIME      NOT NULL,
    [InvoiceInAdvance]     TINYINT       CONSTRAINT [DF_BillingPeriodDefinition_InvoiceInAdvance] DEFAULT ((0)) NOT NULL,
    [ManuallyCreated]      BIT           CONSTRAINT [df_BillingPeriodDefinition_ManuallyCreated] DEFAULT ((0)) NOT NULL,
    [PaymentMethodId]      BIGINT        NULL,
    [AutoCollect]          BIT           NULL,
    [AutoPost]             BIT           NULL,
    [TermId]               INT           NULL,
    [PoNumber]             VARCHAR (255) NULL,
    [QuickBooksLocationId] BIGINT        CONSTRAINT [DF_QuickBooksLocationId] DEFAULT (NULL) NULL,
    [InvoiceWeekday]       INT           NULL,
    CONSTRAINT [PK_BillingPeriodDefinition] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([InvoiceWeekday]) REFERENCES [Lookup].[Weekday] ([Id]),
    CONSTRAINT [FK_BillingPeriodDefinition_BillingPeriodType] FOREIGN KEY ([BillingPeriodTypeId]) REFERENCES [Lookup].[BillingPeriodType] ([Id]),
    CONSTRAINT [FK_BillingPeriodDefinition_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([Id]),
    CONSTRAINT [FK_BillingPeriodDefinition_Interval] FOREIGN KEY ([IntervalId]) REFERENCES [Lookup].[Interval] ([Id]),
    CONSTRAINT [FK_BillingPeriodDefinition_PaymentMethod] FOREIGN KEY ([PaymentMethodId]) REFERENCES [dbo].[PaymentMethod] ([Id]),
    CONSTRAINT [FK_BillingPeriodDefinition_TermId] FOREIGN KEY ([TermId]) REFERENCES [Lookup].[Term] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [FKIX_BillingPeriodDefinition_IntervalId]
    ON [dbo].[BillingPeriodDefinition]([IntervalId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

CREATE NONCLUSTERED INDEX [IX_BillingPeriodDefinition_CustomerId_PaymentMethodId]
    ON [dbo].[BillingPeriodDefinition]([CustomerId] ASC, [PaymentMethodId] ASC) WITH (FILLFACTOR = 100);


GO

