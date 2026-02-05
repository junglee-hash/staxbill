CREATE TABLE [dbo].[Earning] (
    [Id]        BIGINT         NOT NULL,
    [ChargeId]  BIGINT         NOT NULL,
    [Reference] NVARCHAR (500) NULL,
    CONSTRAINT [PK_Earning] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Earning_Charge] FOREIGN KEY ([ChargeId]) REFERENCES [dbo].[Charge] ([Id]),
    CONSTRAINT [FK_Earning_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_Earning_ChargeId]
    ON [dbo].[Earning]([ChargeId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

