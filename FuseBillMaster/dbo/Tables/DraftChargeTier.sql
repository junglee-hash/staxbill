CREATE TABLE [dbo].[DraftChargeTier] (
    [Id]            BIGINT          IDENTITY (1, 1) NOT NULL,
    [DraftChargeId] BIGINT          NOT NULL,
    [Label]         VARCHAR (100)   NOT NULL,
    [Quantity]      DECIMAL (18, 6) NOT NULL,
    [UnitPrice]     DECIMAL (18, 6) NOT NULL,
    [Amount]        MONEY           NOT NULL,
    [SortOrder]     INT             CONSTRAINT [df_DraftChargeTier_SortOrder] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_DraftChargeTier] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DraftChargeTier_DraftCharge] FOREIGN KEY ([DraftChargeId]) REFERENCES [dbo].[DraftCharge] ([Id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [FKIX_DraftChargeTier_DraftChargeId]
    ON [dbo].[DraftChargeTier]([DraftChargeId] ASC) WITH (FILLFACTOR = 100);


GO

