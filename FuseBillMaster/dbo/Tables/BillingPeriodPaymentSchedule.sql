CREATE TABLE [dbo].[BillingPeriodPaymentSchedule] (
    [Id]                        BIGINT   IDENTITY (1, 1) NOT NULL,
    [BillingPeriodDefinitionId] BIGINT   NOT NULL,
    [Amount]                    MONEY    NOT NULL,
    [DaysDueAfterTerm]          INT      NOT NULL,
    [CreatedTimestamp]          DATETIME NOT NULL,
    [ModifiedTimestamp]         DATETIME NOT NULL,
    CONSTRAINT [PK_BillingPeriodPaymentSchedule] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_BillingPeriodPaymentSchedule_BillingPeriodDefinition] FOREIGN KEY ([BillingPeriodDefinitionId]) REFERENCES [dbo].[BillingPeriodDefinition] ([Id])
);


GO

