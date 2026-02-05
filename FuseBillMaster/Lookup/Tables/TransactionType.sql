CREATE TABLE [Lookup].[TransactionType] (
    [Id]                  INT           NOT NULL,
    [Name]                VARCHAR (500) NOT NULL,
    [ARBalanceMultiplier] INT           NOT NULL,
    [SortOrder]           INT           NOT NULL,
    CONSTRAINT [PK_TransactionType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

