CREATE TABLE [dbo].[OpeningBalance] (
    [Id]                BIGINT          NOT NULL,
    [Reference]         NVARCHAR (500)  NULL,
    [UnallocatedAmount] DECIMAL (18, 6) NOT NULL,
    CONSTRAINT [PK_OpeningBalance] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OpeningBalance_Transaction] FOREIGN KEY ([Id]) REFERENCES [dbo].[Transaction] ([Id])
);


GO

