
CREATE PROCEDURE [dbo].[usp_GetFullDraftChargeBySubscriptionId]
	@SubscriptionId bigint
	,@CustomerIds dbo.IdList READONLY
	, @ProjectedOnly bit
AS
BEGIN
	set transaction isolation level snapshot

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #DraftCharges
	(
		DraftChargeId BIGINT PRIMARY KEY CLUSTERED
	)

	INSERT INTO #DraftCharges
	SELECT dspc.Id
	FROM DraftSubscriptionProductCharge dspc
	INNER JOIN DraftCharge dc ON dc.Id = dspc.Id
		AND (@ProjectedOnly = 0
            OR  @ProjectedOnly = 1 AND dc.StatusId = 4)
	INNER JOIN SubscriptionProduct sp ON sp.Id = dspc.SubscriptionProductId
	INNER JOIN @CustomerIds c ON c.Id = dc.CustomerId
	WHERE sp.SubscriptionId = @SubscriptionId

	SELECT dc.*
		, dc.TransactionTypeId as TransactionType
		, dc.StatusId as [Status]
		, dc.EarningTimingTypeId as EarningTimingType
		, dc.EarningTimingIntervalId as EarningTimingInterval
	FROM [dbo].[DraftCharge] dc
	INNER JOIN #DraftCharges di ON di.DraftChargeId = dc.Id

	SELECT dt.*
	FROM [dbo].[DraftTax] dt
	INNER JOIN #DraftCharges di ON di.DraftChargeId = dt.DraftChargeId

	SELECT dd.*
		, dd.DiscountTypeId as DiscountType
		, dd.TransactionTypeId as TransactionType
	FROM [dbo].[DraftDiscount] dd
	INNER JOIN #DraftCharges di ON di.DraftChargeId = dd.DraftChargeId

	SELECT dspc.*
	FROM [dbo].[DraftSubscriptionProductCharge] dspc
	INNER JOIN #DraftCharges di ON di.DraftChargeId = dspc.Id

	SELECT dt.*
	FROM [dbo].[DraftChargeTier] dt
	INNER JOIN #DraftCharges di ON di.DraftChargeId = dt.DraftChargeId

	SELECT spajdc.*
	FROM [dbo].[SubscriptionProductActivityJournalDraftCharge] spajdc
	INNER JOIN #DraftCharges di ON di.DraftChargeId = spajdc.DraftChargeId

	DROP TABLE #DraftCharges
END

GO

