CREATE TABLE [dbo].[CustomerStartingData] (
    [Id]                    BIGINT          NOT NULL,
    [OpeningBalance]        DECIMAL (18, 6) NOT NULL,
    [PreviousLifetimeValue] DECIMAL (18, 6) NOT NULL,
    [CreatedTimestamp]      DATETIME        NOT NULL,
    CONSTRAINT [PK_CustomerStartingData] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CustomerStartingData_Customer] FOREIGN KEY ([Id]) REFERENCES [dbo].[Customer] ([Id])
);


GO

