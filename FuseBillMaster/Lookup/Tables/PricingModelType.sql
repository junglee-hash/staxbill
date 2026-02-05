CREATE TABLE [Lookup].[PricingModelType] (
    [Id]   INT          NOT NULL,
    [Name] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_PricingModelType] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PricingModelType_PricingModelType] FOREIGN KEY ([Id]) REFERENCES [Lookup].[PricingModelType] ([Id])
);


GO

