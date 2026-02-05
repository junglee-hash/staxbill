CREATE TABLE [dbo].[Transaction_Earning] (
    [Id]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [CreatedTimestamp]   DATETIME        NOT NULL,
    [CustomerId]         BIGINT          NOT NULL,
    [Amount]             MONEY           NOT NULL,
    [EffectiveTimestamp] DATETIME        NOT NULL,
    [TransactionTypeId]  INT             NOT NULL,
    [Description]        NVARCHAR (2000) NULL,
    [CurrencyId]         BIGINT          NOT NULL,
    [SortOrder]          INT             NOT NULL,
    [AccountId]          BIGINT          NOT NULL,
    [ModifiedTimestamp]  DATETIME        NULL,
    [ChargeId]           BIGINT          NOT NULL
);


GO

