CREATE TABLE [Lookup].[Currency] (
    [Id]                BIGINT        NOT NULL,
    [IsoName]           VARCHAR (50)  NOT NULL,
    [Symbol]            NVARCHAR (10) NOT NULL,
    [DecimalMultiplier] INT           NOT NULL,
    CONSTRAINT [PK_Currency] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

