CREATE TABLE [Lookup].[PlanProductStatus] (
    [Id]   INT           NOT NULL,
    [Name] VARCHAR (100) NOT NULL,
    CONSTRAINT [pk_PlanProductStatus] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

