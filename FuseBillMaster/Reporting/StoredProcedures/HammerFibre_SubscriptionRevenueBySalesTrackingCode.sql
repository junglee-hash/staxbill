
CREATE PROCEDURE [Reporting].[HammerFibre_SubscriptionRevenueBySalesTrackingCode]
	@AccountId bigint = 21579
AS
BEGIN

DECLARE
@StartDate datetime ='2010-01-01'
,@EndDate datetime = '2050-01-01' --effectively all time
,@CurrencyId bigint = 1 

set transaction isolation level snapshot
set nocount on

declare @TimezoneId INT

SELECT @TimezoneId = TimezoneId
FROM AccountPreference
WHERE Id = @AccountId

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
	Result.[Subscription ID] as SubscriptionId
	,Result.PlanName as SubscriptionName
	,result.[Plan Code] as PlanCode
	,ss.Name as SubscriptionStatus
	,CONVERT(nvarchar, CONVERT(date,dbo.fn_GetTimezoneTime(result.SubscriptionActivationTimestamp,@TimezoneId)),120) as SubscriptionActivationDate
	,ISNULL(CONVERT(nvarchar, CONVERT(date,dbo.fn_GetTimezoneTime(result.SubscriptionCancellationTimestamp,@TimezoneId)),120),'') as SubscriptionCancellationDate
	,result.[Earned Amount as of Report Date] - result.[Earned Discount as of Report Date] as TotalNetEarnedRevenue
	, c.Id as FusebillId
	,ISNULL(c.FirstName,'') as CustomerFirstName
	,ISNULL(c.LastName,'') as CustomerLastName
	,ISNULL(c.CompanyName,'') as CustomerCompanyName
	,ISNULL(stc1.Code,'') as SalesTrackingCode1Code
	,ISNULL(stc1.Name,'') as SalesTrackingCode1Name
	,ISNULL(stc2.Code,'') as SalesTrackingCode2Code
	,ISNULL(stc2.Name,'') as SalesTrackingCode2Name
	,ISNULL(stc3.Code,'') as SalesTrackingCode3Code
	,ISNULL(stc3.Name,'') as SalesTrackingCode3Name
	,ISNULL(stc4.Code,'') as SalesTrackingCode4Code
	,ISNULL(stc4.Name,'') as SalesTrackingCode4Name
	,ISNULL(stc5.Code,'') as SalesTrackingCode5Code
	,ISNULL(stc5.Name,'') as SalesTrackingCode5Name
	FROM (
-- Get all subscription type charges
	 SELECT 
		t.CustomerId
		, s.PlanCode as [Plan Code]
		, s.Id as [Subscription ID]
		,s.PlanName
		, s.StatusId as SubscriptionStatus
		, s.ActivationTimestamp as SubscriptionActivationTimestamp
		,s.CancellationTimestamp as SubscriptionCancellationTimestamp
		, sum(temp.EarnedCreditAll - temp.EarnedDebitAll) as [Earned Amount as of Report Date]
		, sum(temp.DiscountDebitAll - temp.DiscountCreditAll) as [Earned Discount as of Report Date]
		, sum(temp.DeferredCreditAll - temp.DeferredDebitAll) as [Deferred Amount as of Report Date]
		, sum(temp.DeferredDiscountDebitAll - temp.DeferredDiscountCreditAll) as [Deferred Discount as of Report Date]
	FROM #ResultTable temp
	INNER JOIN [Transaction] t ON t.Id = temp.ChargeId
	INNER JOIN Charge ch ON t.Id = ch.Id
	INNER JOIN SubscriptionProductCharge spc ON spc.Id = ch.Id
	INNER JOIN SubscriptionProduct sp ON sp.Id = spc.SubscriptionProductId
	INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
	GROUP BY t.CustomerId, s.PlanCode, s.Id, s.StatusId, s.ActivationTimestamp, s.CancellationTimestamp, s.PlanName
	
)Result
	INNER JOIN Customer c ON c.Id = CustomerId
	INNER JOIN Lookup.SubscriptionStatus ss ON ss.Id = Result.SubscriptionStatus
	INNER JOIN CustomerReference cr ON cr.Id = c.Id
	LEFT JOIN SalesTrackingCode stc1 ON stc1.Id = cr.SalesTrackingCode1Id
	LEFT JOIN SalesTrackingCode stc2 ON stc2.Id = cr.SalesTrackingCode2Id
	LEFT JOIN SalesTrackingCode stc3 ON stc3.Id = cr.SalesTrackingCode3Id
	LEFT JOIN SalesTrackingCode stc4 ON stc4.Id = cr.SalesTrackingCode4Id
	LEFT JOIN SalesTrackingCode stc5 ON stc5.Id = cr.SalesTrackingCode5Id

--select * from #ResultTable

DROP TABLE #ResultTable


END

GO

