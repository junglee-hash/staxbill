CREATE TABLE [dbo].[DiscountConfigurationFrequency] (
    [Id]                        BIGINT          IDENTITY (1, 1) NOT NULL,
    [DiscountConfigurationId]   BIGINT          NOT NULL,
    [IntervalId]                INT             NOT NULL,
    [NumberOfIntervals]         INT             NOT NULL,
    [RemainingUsagesUntilStart] INT             NOT NULL,
    [RemainingUsage]            INT             NULL,
    [Amount]                    DECIMAL (18, 6) NOT NULL,
    [DiscountTypeId]            INT             NOT NULL,
    CONSTRAINT [PK_DiscountConfigurationFrequency] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_DiscountConfigurationFrequency_DiscountConfiguration] FOREIGN KEY ([DiscountConfigurationId]) REFERENCES [dbo].[DiscountConfiguration] ([Id]),
    CONSTRAINT [FK_DiscountConfigurationFrequency_DiscountType] FOREIGN KEY ([DiscountTypeId]) REFERENCES [Lookup].[DiscountType] ([Id]),
    CONSTRAINT [FK_DiscountConfigurationFrequency_Interval] FOREIGN KEY ([IntervalId]) REFERENCES [Lookup].[Interval] ([Id])
);


GO

