
CREATE procedure [Reporting].[Crelate_UnearnedRevenueReport]
--declare
@AccountId bigint --= 3217131
,@StartDate datetime --= '2017-01-01'
,@EndDate datetime --= '2018-01-01'

as

set transaction isolation level snapshot

declare @TimezoneId int
,@CurrencyId bigint = 1 

select @TimezoneId = TimezoneId
from AccountPreference where Id = @AccountId 

create table #ResultTable
(
ChargeId bigint primary Key
,EarnedDebitAll money
,EarnedCreditAll money
,DiscountDebitAll money
,DiscountCreditAll money
,DeferredDebitAll money
,DeferredCreditAll money
,DeferredDiscountDebitAll money
,DeferredDiscountCreditAll money
,EarnedDebitInPeriod money
,EarnedCreditInPeriod money
,DiscountDebitInPeriod money
,DiscountCreditInPeriod money
,DeferredDebitInPeriod money
,DeferredCreditInPeriod money
,DeferredDiscountDebitInPeriod money
,DeferredDiscountCreditInPeriod money
)

insert into #ResultTable 
SELECT * FROM 
dbo.ChargesWithRevenueMoves(@AccountId, @StartDate, @EndDate, @CurrencyId)

SELECT 
	Result.[Transaction ID]
	, tt.Name as [Transaction Type]
	, Result.Name
	, Result.[Description]
	, Result.[Plan Code]
	, Result.[Product Code]
	, ISNULL(gl.Code, '') as [GL Code]
	, Result.[Subscription ID]
	, Result.[Purchase ID]
	, Result.[Posted Date]
	, Result.[Service Start]
	, Result.[Service End]
	, Result.[Invoice ID]
	, Result.[Invoice Number]
	, cur.IsoName as [Currency]
	, Result.[Original Charge Amount]
	, Result.[Original Discount Amount]
	, Result.[Earned Amount as of Report Date]
	, Result.[Earned Discount as of Report Date]
	, Result.[Deferred Amount as of Report Date]
	, Result.[Deferred Discount as of Report Date]
	, eti.Name as [Earning Interval]
	, ett.Name as [Earning Timing]
	, Result.[Earning Start Date]
	, Result.[Earning End Date]
	, Result.[Number of Days]
	, Result.[Interval Frequency]
	, Result.[Earnings per Day]
	, Result.[Deferred Revenue Debit]
	, Result.[Deferred Revenue Credit]
	, Result.[Deferred Discount Debit]
	, Result.[Deferred Discount Credit]
	, Customer.*
	FROM (
-- Get all subscription type charges
	 SELECT t.Id as [Transaction ID]
		, t.CustomerId
		, t.TransactionTypeId
		, ch.Name
		, ISNULL(t.[Description], '') as [Description]
		, s.PlanCode as [Plan Code]
		, sp.PlanProductCode as [Product Code]
		, ch.GLCodeId
		, s.Id as [Subscription ID]
		, NULL as [Purchase ID]
		, dbo.fn_GetTimezoneTime(t.EffectiveTimestamp, @TimezoneId) as [Posted Date]
		, dbo.fn_GetTimezoneTime(spc.StartServiceDateLabel, @TimezoneId) as [Service Start]
		, dbo.fn_GetTimezoneTime(spc.EndServiceDateLabel, @TimezoneId) as [Service End]
		, ch.InvoiceId as [Invoice ID]
		, i.InvoiceNumber as [Invoice Number]
		, t.CurrencyId
		, t.Amount as [Original Charge Amount]
		, ISNULL(SUM(dtran.Amount), 0) as [Original Discount Amount]
		, temp.EarnedCreditAll - temp.EarnedDebitAll as [Earned Amount as of Report Date]
		, temp.DiscountDebitAll - temp.DiscountCreditAll as [Earned Discount as of Report Date]
		, temp.DeferredCreditAll - temp.DeferredDebitAll as [Deferred Amount as of Report Date]
		, temp.DeferredDiscountDebitAll - temp.DeferredDiscountCreditAll as [Deferred Discount as of Report Date]
		, ch.EarningTimingIntervalId
		, ch.EarningTimingTypeId
		, dbo.fn_GetTimezoneTime(ch.EarningStartDate, @TimezoneId) as [Earning Start Date]
		, dbo.fn_GetTimezoneTime(ch.EarningEndDate, @TimezoneId) as [Earning End Date]
		, temp.DeferredDebitInPeriod as [Deferred Revenue Debit]
		, temp.DeferredCreditInPeriod as [Deferred Revenue Credit]
		, temp.DeferredDiscountDebitInPeriod as [Deferred Discount Debit]
		, temp.DeferredDiscountCreditInPeriod as [Deferred Discount Credit]
		, DATEDIFF(dd,ch.EarningStartDate, ch.EarningEndDate) as [Number of days]
		, s.NumberOfIntervals as [Interval Frequency]
		, case
			WHEN DATEDIFF(dd,ch.EarningStartDate, ch.EarningEndDate) > 0 
			THEN
			 t.Amount/DATEDIFF(dd,ch.EarningStartDate, ch.EarningEndDate) 
			ELSE
			 0
			END as [Earnings per Day]
	FROM #ResultTable temp
	INNER JOIN [Transaction] t ON t.Id = temp.ChargeId
	INNER JOIN Charge ch ON t.Id = ch.Id
	INNER JOIN SubscriptionProductCharge spc ON spc.Id = ch.Id
	INNER JOIN SubscriptionProduct sp ON sp.Id = spc.SubscriptionProductId
	INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
	INNER JOIN Invoice i ON i.Id = ch.InvoiceId
	LEFT JOIN Discount d ON ch.Id = d.ChargeId
	LEFT JOIN [Transaction] dtran ON dtran.Id = d.Id
	GROUP BY t.Id, t.CustomerId, t.TransactionTypeId, ch.Name, t.[Description], s.PlanCode
		, sp.PlanProductCode, ch.GLCodeId, s.Id, t.EffectiveTimestamp, spc.StartServiceDateLabel, spc.EndServiceDateLabel
		, ch.InvoiceId, i.InvoiceNumber, t.CurrencyId, t.Amount, temp.EarnedCreditAll, temp.EarnedDebitAll
		, temp.DiscountDebitAll, temp.DiscountCreditAll, temp.DeferredCreditAll, temp.DeferredDebitAll
		, temp.DeferredDiscountDebitAll, temp.DeferredDiscountCreditAll, ch.EarningTimingIntervalId, ch.EarningTimingTypeId
		, ch.EarningStartDate, ch.EarningEndDate, temp.DeferredDebitInPeriod, temp.DeferredCreditInPeriod
		, temp.DeferredDiscountDebitInPeriod, temp.DeferredDiscountCreditInPeriod, s.NumberOfIntervals

-- Union all purchase type charges
UNION ALL

	SELECT t.Id as [Transaction ID]
		, t.CustomerId
		, t.TransactionTypeId
		, ch.Name
		, ISNULL(t.[Description], '') as [Description]
		, '' as [Plan Code]
		, pp.Code as [Product Code]
		, ch.GLCodeId
		, NULL as [Subscription ID]
		, p.Id as [Purchase ID]
		, dbo.fn_GetTimezoneTime(t.EffectiveTimestamp, @TimezoneId) as [Posted Date]
		, NULL as [Service Start]
		, NULL as [Service End]
		, ch.InvoiceId as [Invoice ID]
		, i.InvoiceNumber as [Invoice Number]
		, t.CurrencyId
		, t.Amount as [Original Charge Amount]
		, ISNULL(SUM(dtran.Amount), 0) as [Original Discount Amount]
		, temp.EarnedCreditAll - temp.EarnedDebitAll as [Earned Amount as of Report Date]
		, temp.DiscountDebitAll - temp.DiscountCreditAll as [Earned Discount as of Report Date]
		, temp.DeferredCreditAll - temp.DeferredDebitAll as [Deferred Amount as of Report Date]
		, temp.DeferredDiscountDebitAll - temp.DeferredDiscountCreditAll as [Deferred Discount as of Report Date]
		, ch.EarningTimingIntervalId
		, ch.EarningTimingTypeId
		, dbo.fn_GetTimezoneTime(ch.EarningStartDate, @TimezoneId) as [Earning Start Date]
		, dbo.fn_GetTimezoneTime(ch.EarningEndDate, @TimezoneId) as [Earning End Date]
		, temp.DeferredDebitInPeriod as [Deferred Revenue Debit]
		, temp.DeferredCreditInPeriod as [Deferred Revenue Credit]
		, temp.DeferredDiscountDebitInPeriod as [Deferred Discount Debit]
		, temp.DeferredDiscountCreditInPeriod as [Deferred Discount Credit]
		, null as [Number of Days]
		, null as [Interval Frequency]
		, null as [Earnings per Day]
	FROM #ResultTable temp
	INNER JOIN [Transaction] t ON t.Id = temp.ChargeId
	INNER JOIN Charge ch ON t.Id = ch.Id
	INNER JOIN PurchaseCharge pc ON pc.Id = ch.Id
	INNER JOIN Purchase p ON p.Id = pc.PurchaseId
	INNER JOIN Product pp ON pp.Id = p.ProductId
	INNER JOIN Invoice i ON i.Id = ch.InvoiceId
	LEFT JOIN Discount d ON ch.Id = d.ChargeId
	LEFT JOIN [Transaction] dtran ON dtran.Id = d.Id
	GROUP BY t.Id , t.CustomerId, t.TransactionTypeId, ch.Name, t.[Description], pp.Code, ch.GLCodeId
		, p.Id, t.EffectiveTimestamp, ch.InvoiceId, i.InvoiceNumber, t.CurrencyId, t.Amount
		, temp.EarnedCreditAll, temp.EarnedDebitAll, temp.DiscountDebitAll, temp.DiscountCreditAll
		, temp.DeferredCreditAll, temp.DeferredDebitAll, temp.DeferredDiscountDebitAll, temp.DeferredDiscountCreditAll
		, ch.EarningTimingIntervalId, ch.EarningTimingTypeId, ch.EarningStartDate, ch.EarningEndDate
		, temp.DeferredDebitInPeriod, temp.DeferredCreditInPeriod, temp.DeferredDiscountDebitInPeriod, temp.DeferredDiscountCreditInPeriod

-- Union all opening deferred revenue type charges
UNION ALL
	SELECT t.Id as [Transaction ID]
		, t.CustomerId
		, t.TransactionTypeId
		, '' as Name
		, ISNULL(t.[Description], '') as [Description]
		, '' as [Plan Code]
		, '' as [Product Code]
		, odr.GlCodeId
		, NULL as [Subscription ID]
		, NULL as [Purchase ID]
		, dbo.fn_GetTimezoneTime(t.EffectiveTimestamp, @TimezoneId) as [Posted Date]
		, NULL as [Service Start]
		, NULL as [Service End]
		, NULL as [Invoice ID]
		, NULL as [Invoice Number]
		, t.CurrencyId
		, t.Amount as [Original Charge Amount]
		, 0 as [Original Discount Amount]
		, temp.EarnedCreditAll - temp.EarnedDebitAll as [Earned Amount as of Report Date]
		, temp.DiscountDebitAll - temp.DiscountCreditAll as [Earned Discount as of Report Date]
		, temp.DeferredCreditAll - temp.DeferredDebitAll as [Deferred Amount as of Report Date]
		, temp.DeferredDiscountDebitAll - temp.DeferredDiscountCreditAll as [Deferred Discount as of Report Date]
		, odr.EarningTimingIntervalId
		, odr.EarningTimingTypeId
		, dbo.fn_GetTimezoneTime(odr.EarningStartDate, @TimezoneId) as [Earning Start Date]
		, dbo.fn_GetTimezoneTime(odr.EarningEndDate, @TimezoneId) as [Earning End Date]
		, temp.DeferredDebitInPeriod as [Deferred Revenue Debit]
		, temp.DeferredCreditInPeriod as [Deferred Revenue Credit]
		, temp.DeferredDiscountDebitInPeriod as [Deferred Discount Debit]
		, temp.DeferredDiscountCreditInPeriod as [Deferred Discount Credit]
		, null as [Number of Days]
		, null as [Interval Frequency]
		, null as [Earnings per Day]
	FROM #ResultTable temp
	INNER JOIN [Transaction] t ON t.Id = temp.ChargeId
	INNER JOIN OpeningDeferredRevenue odr ON t.Id = odr.Id
)Result
	INNER JOIN Lookup.TransactionType tt on tt.Id = TransactionTypeId
	LEFT JOIN GLCode gl ON gl.Id = GLCodeId
	INNER JOIN Lookup.Currency cur ON cur.Id = CurrencyId
	INNER JOIN Lookup.EarningTimingInterval eti ON eti.Id = EarningTimingIntervalId
	INNER JOIN Lookup.EarningTimingType ett ON ett.Id = EarningTimingTypeId
	CROSS APPLY dbo.BasicCustomerData(CustomerId) Customer

--select * from #ResultTable

DROP TABLE #ResultTable

GO

