Create   PROCEDURE [dbo].[usp_DatafixSubscriptionProductProrationValues]
	@AccountId BIGINT,
	@PlanProductCode nvarchar(1000)
AS

	UPDATE 
		sp
	SET 
		--Quantity proration
	    sp.QuantityProrateNegativeQuantity = pocc.QuantityProrateNegativeQuantity,
		sp.QuantityProratePositiveQuantity = pocc.QuantityProratePositiveQuantity,

		--Recurring proration
		sp.RecurProratePositiveQuantity = pocc.RecurProratePositiveQuantity,
		sp.RecurProrateNegativeQuantity = pocc.RecurProrateNegativeQuantity,

		--Reversal proration
		sp.QuantityReverseChargeNegativeQuantity = pocc.QuantityReverseChargeNegativeQuantity,
		sp.RecurReverseChargeNegativeQuantity = pocc.RecurReverseChargeNegativeQuantity,

		--Proration Granularity
		sp.RecurProrateGranularityId = pocc.RecurProrateGranularityId,
		sp.QuantityProrateGranularityId = pocc.QuantityProrateGranularityId,

		--Modified timestamp
		sp.ModifiedTimestamp = GETUTCDATE()
	FROM SubscriptionProduct sp
	INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
	INNER JOIN PlanOrderToCashCycle pocc ON pocc.PlanProductId = sp.PlanProductId AND pocc.PlanFrequencyId = s.PlanFrequencyId
	INNER JOIN PlanProduct pp on pp.Id = sp.PlanProductId
	INNER JOIN Customer c ON c.Id = s.CustomerId
	WHERE 
		c.AccountId = @AccountId 
		AND pp.Code = @PlanProductCode
		AND sp.RecurChargeTimingTypeId != 3 -- Not equal to end of period
		AND sp.QuantityChargeTimingTypeId != 3 -- Not equal to end of period
		AND pocc.RecurChargeTimingTypeId != 3 -- Not equal to end of period
		AND pocc.QuantityChargeTimingTypeId != 3 -- Not equal to end of period

GO

