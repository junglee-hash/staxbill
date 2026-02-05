CREATE TABLE [dbo].[ChargeTier] (
    [Id]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [ChargeId]  BIGINT          NOT NULL,
    [Label]     VARCHAR (100)   NOT NULL,
    [Quantity]  DECIMAL (18, 6) NOT NULL,
    [UnitPrice] DECIMAL (18, 6) NOT NULL,
    [Amount]    MONEY           NOT NULL,
    [SortOrder] INT             CONSTRAINT [df_ChargeTier_SortOrder] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_ChargeTier] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_ChargeTier_Charge] FOREIGN KEY ([ChargeId]) REFERENCES [dbo].[Charge] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_ChargeTier_ChargeId]
    ON [dbo].[ChargeTier]([ChargeId] ASC) WITH (FILLFACTOR = 100);


GO

