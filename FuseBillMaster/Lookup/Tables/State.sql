CREATE TABLE [Lookup].[State] (
    [Id]                 BIGINT         NOT NULL,
    [Name]               NVARCHAR (250) NOT NULL,
    [CountryId]          BIGINT         NOT NULL,
    [SubdivisionISOCode] VARCHAR (10)   NULL,
    [CombinedISOCode]    VARCHAR (10)   NULL,
    CONSTRAINT [PK_State] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_State_Country] FOREIGN KEY ([CountryId]) REFERENCES [Lookup].[Country] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_State_CountryId]
    ON [Lookup].[State]([CountryId] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

