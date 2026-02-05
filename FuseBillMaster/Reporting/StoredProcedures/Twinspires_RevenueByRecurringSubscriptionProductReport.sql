
/*
This is basically the stock earned revenue report minus the purchases and only run for 10 specific plans and only on recurring products
Plans: ('plan101m', 'plan201m', 'plan203m', 'plan301a', 'plan301m', 'plan302m', 'plan303m', 'plan304m', 'plan305m', 'plan306m')

UPDATE REQUEST https://fusebilldev.visualstudio.com/Fusebill/_workitems/edit/5260
removing planCode as a filter.  leaving the isRecurring as the sole subscription filter
*/

create procedure [Reporting].[Twinspires_RevenueByRecurringSubscriptionProductReport]

@AccountId bigint 
,@StartDate datetime 
,@EndDate datetime 

as

set nocount on
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
	, Result.Name
	, Result.[Description]
	, Result.[Plan Code]
	, Result.[Product Code]
	, ISNULL(gl.Code, '') as [GL Code]
	, Result.[Subscription ID]
	, Result.[Posted Date]
	, Result.[Service Start]
	, Result.[Service End]
	, Result.[Invoice ID]
	, Result.[Invoice Number]
	, Result.[Original Charge Amount]
	, Result.[Original Discount Amount]
	, Result.[Deferred Amount as of Report Date]
	, Result.[Deferred Discount as of Report Date]
	, eti.Name as [Earning Interval]
	, ett.Name as [Earning Timing]
	, Result.[Earning Start Date]
	, Result.[Earning End Date]
	, Result.[Earned Revenue Debit]
	, Result.[Earned Revenue Credit]
	, Result.[Discount Debit]
	, Result.[Discount Credit]
	, Customer.Id as [Fusebill ID]
	, Customer.Reference as [Customer ID]
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
		, temp.EarnedDebitInPeriod as [Earned Revenue Debit]
		, temp.EarnedCreditInPeriod as [Earned Revenue Credit]
		, temp.DiscountDebitInPeriod as [Discount Debit]
		, temp.DiscountCreditInPeriod as [Discount Credit]
	FROM #ResultTable temp
	INNER JOIN [Transaction] t ON t.Id = temp.ChargeId
	INNER JOIN Charge ch ON t.Id = ch.Id
	INNER JOIN SubscriptionProductCharge spc ON spc.Id = ch.Id
	INNER JOIN SubscriptionProduct sp ON sp.Id = spc.SubscriptionProductId and sp.IsRecurring = 1 
	INNER JOIN Subscription s ON s.Id = sp.SubscriptionId --and s.PlanCode in ('plan101m', 'plan201m', 'plan203m', 'plan301a', 'plan301m', 'plan302m', 'plan303m', 'plan304m', 'plan305m', 'plan306m')
	INNER JOIN Invoice i ON i.Id = ch.InvoiceId
	LEFT JOIN Discount d ON ch.Id = d.ChargeId
	LEFT JOIN [Transaction] dtran ON dtran.Id = d.Id
	GROUP BY t.Id, t.CustomerId, t.TransactionTypeId, ch.Name, t.[Description], s.PlanCode
		, sp.PlanProductCode, ch.GLCodeId, s.Id, t.EffectiveTimestamp, spc.StartServiceDateLabel, spc.EndServiceDateLabel
		, ch.InvoiceId, i.InvoiceNumber, t.CurrencyId, t.Amount, temp.EarnedCreditAll, temp.EarnedDebitAll
		, temp.DiscountDebitAll, temp.DiscountCreditAll, temp.DeferredCreditAll, temp.DeferredDebitAll
		, temp.DeferredDiscountDebitAll, temp.DeferredDiscountCreditAll, ch.EarningTimingIntervalId, ch.EarningTimingTypeId
		, ch.EarningStartDate, ch.EarningEndDate, temp.EarnedDebitInPeriod, temp.EarnedCreditInPeriod
		, temp.DiscountDebitInPeriod, temp.DiscountCreditInPeriod
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
		, temp.EarnedDebitInPeriod as [Earned Revenue Debit]
		, temp.EarnedCreditInPeriod as [Earned Revenue Credit]
		, temp.DiscountDebitInPeriod as [Discount Debit]
		, temp.DiscountCreditInPeriod as [Discount Credit]
	FROM #ResultTable temp
	INNER JOIN [Transaction] t ON t.Id = temp.ChargeId
	INNER JOIN OpeningDeferredRevenue odr ON t.Id = odr.Id
)Result
	INNER JOIN Lookup.TransactionType tt on tt.Id = TransactionTypeId
	LEFT JOIN GLCode gl ON gl.Id = GLCodeId
	INNER JOIN Lookup.Currency cur ON cur.Id = CurrencyId
	INNER JOIN Lookup.EarningTimingInterval eti ON eti.Id = EarningTimingIntervalId
	INNER JOIN Lookup.EarningTimingType ett ON ett.Id = EarningTimingTypeId
	INNER JOIN Customer Customer ON Customer.Id = Result.CustomerId

	Order by Customer.Id, Result.[Subscription ID]

DROP TABLE #ResultTable

GO

