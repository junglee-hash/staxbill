CREATE TABLE [Lookup].[Interval] (
    [Id]            INT            NOT NULL,
    [Name]          VARCHAR (50)   NOT NULL,
    [MRRMultiplier] DECIMAL (9, 6) NOT NULL,
    CONSTRAINT [PK_Interval] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

