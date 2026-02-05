CREATE TABLE [dbo].[PlanFrequencyCouponCode] (
    [Id]                    BIGINT   IDENTITY (1, 1) NOT NULL,
    [CouponCodeId]          BIGINT   NOT NULL,
    [CreatedTimestamp]      DATETIME NOT NULL,
    [PlanFrequencyUniqueId] BIGINT   NOT NULL,
    CONSTRAINT [PK_PlanFrequencyCouponCode] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 100),
    CONSTRAINT [FK_PlanFrequencyCouponCode_CouponCode] FOREIGN KEY ([CouponCodeId]) REFERENCES [dbo].[CouponCode] ([Id]),
    CONSTRAINT [fk_PlanFrequencyCouponCode_PlanFrequencyUniqueId] FOREIGN KEY ([PlanFrequencyUniqueId]) REFERENCES [dbo].[PlanFrequencyKey] ([Id]),
    CONSTRAINT [uc_PlanFrequencyCouponCode_PlanFrequency_CouponCode] UNIQUE NONCLUSTERED ([PlanFrequencyUniqueId] ASC, [CouponCodeId] ASC) WITH (FILLFACTOR = 100)
);


GO

