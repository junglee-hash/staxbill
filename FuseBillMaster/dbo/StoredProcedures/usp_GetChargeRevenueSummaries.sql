-- =============================================
-- Author:		dlarkin
-- Create date: 2022-01-06
-- Description:	Sproc used for the ChargeRevenueSummary end point
-- =============================================

CREATE PROCEDURE [dbo].[usp_GetChargeRevenueSummaries]	
	@ChargeIds AS dbo.IDList READONLY,
	@AccountId BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @TimezoneId BIGINT

	SELECT
		@TimezoneId = ap.TimezoneId
	FROM
		AccountPreference ap
	WHERE
		ap.Id = @AccountId

	declare @chargeTransactions table
	(
		[SortOrder] int,
		id bigint,
		Amount money,
		EffectiveTimestamp DATETIME,
		CustomerId BIGINT
	)

	INSERT INTO @chargeTransactions ([SortOrder], id, Amount, EffectiveTimestamp, CustomerId)
		select 
		ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS [SortOrder],
		ids.Id, 
		t.Amount, 
		t.EffectiveTimestamp,
		t.CustomerId
		from @ChargeIds ids
		INNER JOIN [Transaction] t ON t.Id = ids.Id AND t.TransactionTypeId  in (1 ,20) --charge, purchase
		WHERE t.AccountId = @accountId 


	;with
		EarnedRevenue as
			(
			select
				e.ChargeId 
				,sum(t.Amount) as EarnedRevenue
			from 
				Earning e  with (readpast)
				inner join [Transaction] t  with (readpast) on T.Id = e.Id
				INNER JOIN @chargeTransactions ct on ct.id = e.ChargeId
			WHERE t.AccountId = @AccountId
				AND t.TransactionTypeId = 6
			group by 
				e.ChargeId 
			),
		ReversedRevenue as
			(
			Select 
				OriginalChargeId 
				,sum(ReversedEarnedRevenue) as ReversedEarnedRevenue
			from
			(
			select
				rc.OriginalChargeId
				,t.Amount  as ReversedEarnedRevenue
			from 
				ReverseCharge rc  with (readpast)
				inner join ReverseEarning  re  with (readpast) on rc.Id = re.ReverseChargeId
				inner join [Transaction] t with (readpast) on re.Id = t.Id
				INNER JOIN @chargeTransactions ct on ct.id = rc.OriginalChargeId
			WHERE t.AccountId = @AccountId
				AND t.TransactionTypeId = 9

			union all

			select
				rc.OriginalChargeId
				,t.Amount  as ReversedEarnedRevenue
			from 
				ReverseCharge rc  with (readpast)
				inner join  [Transaction] t on rc.Id = t.Id 
				INNER JOIN @chargeTransactions ct on ct.id = rc.OriginalChargeId
			WHERE  
				t.AccountId = @AccountId
				and t.TransactionTypeId = 24
			)Data
			group by 
				OriginalChargeId 
			),
		ReversedCharges as
			(
			Select 
				rc.OriginalChargeId 
				,sum(t.Amount) as Amount
			from 
				ReverseCharge rc  with (readpast)
				inner join  [Transaction] t with (readpast) on rc.Id = t.Id 
				inner join @chargeTransactions ct on rc.OriginalChargeId = ct.Id
			WHERE  
				t.AccountId = @AccountId
				and t.TransactionTypeId in (7, 24)  -- reverse charge
			Group by 
				rc.OriginalChargeId
			),
		DiscountCharges as
			(
			SELECT
				d.ChargeId,
				SUM(t.Amount) as Amount,
				SUM(d.UnearnedAmount) as UnearnedAmount,
				SUM(d.RemainingReversalAmount) - SUM(d.UnearnedAmount) as EarnedAmount
			FROM
				Discount d with (readpast)
				inner join [Transaction] t with (readpast) on d.Id = t.Id 
				inner join @chargeTransactions ct on d.ChargeId = ct.id
			WHERE  
				t.AccountId = @AccountId
				and t.TransactionTypeId in (14, 21) -- discount
			Group by 
				d.ChargeId
			),
		TaxCharges as
			(
			SELECT
				tx.ChargeId,
				SUM(t.Amount) as Amount
			FROM
				Tax tx with (readpast)
				inner join [Transaction] t with (readpast) on tx.Id = t.Id 
				inner join @chargeTransactions ct on tx.ChargeId = ct.id
			WHERE  
				t.AccountId = @AccountId
				and t.TransactionTypeId = 11 -- tax
			Group by 
				tx.ChargeId
			)

	SELECT  
		c.Id as ChargeId,
		cu.Id as CustomerId,
		cu.Reference as CustomerReference,
		EffectiveTimestamp.TimezoneDateTime as PostedDate,
		spc.StartServiceDateLabel AS ServiceStartDate,
		spc.EndServiceDateLabel AS ServiceEndDate,
		i.Id as InvoiceId,
		i.InvoiceNumber,
		ins.Name as InvoiceStatus,
		ct.Amount,
		ISNULL(dc.Amount,0) as DiscountAmount,
		ISNULL(rc.Amount,0) as ReversalAmount,
		ISNULL(tc.Amount,0) as TaxAmount,
		c.Name as ChargeName,
		cg.Description as ChargeDescription,
		cg.Reference as ChargeReference,
		c.RemainingReverseAmount - isnull(er.EarnedRevenue ,0) + isnull(rr.ReversedEarnedRevenue ,0) as RemainingDeferredRevenue,
		isnull(er.EarnedRevenue,0) - isnull(rr.ReversedEarnedRevenue ,0) AS EarnedRevenueAmount,
		ISNULL(dc.UnearnedAmount,0) as DeferredDiscountAmount,
		ISNULL(dc.EarnedAmount,0) as AccruedDiscountAmount,
		EarningStartDate.TimezoneDateTime as EarningStartDate,
		EarningEndDate.TimezoneDateTime as EarningEndDate,
		ett.Name as EarningTiming,
		eti.Name as EarningInterval,
		CASE 
			WHEN c.EarningTimingIntervalId = 2 Then 'Immediate'
			WHEN c.EarningTimingIntervalId = 7 THEN 'Milestone'
			WHEN c.EarningTimingIntervalId = 3 THEN 'Deposit'
		ELSE 'Time Based'
		END as PerformanceObligationType
	FROM
		Charge c
	INNER JOIN ChargeGroup cg on cg.Id = c.ChargeGroupId
	LEFT JOIN SubscriptionProductCharge spc on spc.Id = c.Id
	INNER JOIN @chargeTransactions ct on ct.Id = c.Id
	INNER JOIN Customer cu on cu.Id = ct.CustomerId
	INNER JOIN Invoice i on i.Id = c.InvoiceId
	INNER JOIN PaymentSchedule AS PS ON PS.InvoiceId = i.Id 
	INNER JOIN PaymentScheduleJournal AS PSJ ON PSJ.PaymentScheduleId = PS.Id AND PSJ.IsActive = 1
	INNER JOIN Lookup.InvoiceStatus ins on ins.Id = PSJ.StatusId
	INNER JOIN Lookup.EarningTimingInterval eti on eti.Id = c.EarningTimingIntervalId
	INNER JOIN Lookup.EarningTimingType ett on ett.Id = c.EarningTimingTypeId
	LEFT JOIN ReversedCharges rc on rc.OriginalChargeId = c.Id
	LEFT JOIN DiscountCharges dc on dc.ChargeId = c.Id
	LEFT JOIN TaxCharges tc on tc.ChargeId = c.Id
	LEFT JOIN EarnedRevenue er on c.Id = er.ChargeId 
	LEFT JOIN ReversedRevenue rr on c.Id = rr.OriginalChargeId 
	CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, ct.EffectiveTimestamp) EffectiveTimestamp
	CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, c.EarningStartDate) EarningStartDate
	OUTER APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, c.EarningEndDate) EarningEndDate
	ORDER BY ct.[SortOrder]

END

GO

