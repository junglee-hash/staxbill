CREATE TABLE [dbo].[AccountAccountingPreference] (
    [Id]                            BIGINT  NOT NULL,
    [LateInvoiceOptionId]           TINYINT NOT NULL,
    [PartialReverseChargeOptionId]  TINYINT CONSTRAINT [df_PartialReverseChargeOptionId] DEFAULT ((1)) NOT NULL,
    [UnsuspendEarningOptionId]      TINYINT CONSTRAINT [df_UnsuspendEarningOptionId] DEFAULT ((1)) NOT NULL,
    [UnholdEarningOptionId]         TINYINT CONSTRAINT [df_UnholdEarningOptionId] DEFAULT ((1)) NOT NULL,
    [MigrationUnearnedIncludeToday] BIT     CONSTRAINT [DF_MigrationUnearnedIncludeToday] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AccountAccountingPreference] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_AccountAccountingPreference_Account] FOREIGN KEY ([Id]) REFERENCES [dbo].[Account] ([Id]),
    CONSTRAINT [FK_AccountAccountingPreference_LateInvoicesOption] FOREIGN KEY ([LateInvoiceOptionId]) REFERENCES [Lookup].[LateInvoicesOption] ([Id]),
    CONSTRAINT [FK_AccountAccountingPreference_PartialReverseChargeOption] FOREIGN KEY ([PartialReverseChargeOptionId]) REFERENCES [Lookup].[PartialReverseChargeOption] ([Id]),
    CONSTRAINT [FK_AccountAccountingPreference_UnholdEarningOption] FOREIGN KEY ([UnholdEarningOptionId]) REFERENCES [Lookup].[UnsuspendEarningOption] ([Id]),
    CONSTRAINT [FK_AccountAccountingPreference_UnsuspendEarningOption] FOREIGN KEY ([UnsuspendEarningOptionId]) REFERENCES [Lookup].[UnsuspendEarningOption] ([Id])
);


GO

