CREATE TABLE [dbo].[CouponEligibility] (
    [Id]        BIGINT   IDENTITY (1, 1) NOT NULL,
    [StartDate] DATETIME NOT NULL,
    [EndDate]   DATETIME NOT NULL,
    CONSTRAINT [PK_CouponEligibility] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON)
);


GO

CREATE NONCLUSTERED INDEX [IX_CouponEligibility_StartDate_EndDate]
    ON [dbo].[CouponEligibility]([StartDate] ASC, [EndDate] ASC)
    INCLUDE([Id]) WITH (FILLFACTOR = 100, STATISTICS_NORECOMPUTE = ON);


GO

