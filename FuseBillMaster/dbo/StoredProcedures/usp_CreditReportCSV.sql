CREATE procedure [dbo].[usp_CreditReportCSV]

@AccountId bigint 
,@UTCSTartDateTime datetime 
,@UTCEndDateTime datetime 
,@CurrencyId bigint = 1 

AS

set transaction isolation level snapshot
if @UTCEndDateTime is null
	set @UTCEndDateTime = getutcdate()
if @UTCSTartDateTime is null
    set @UTCSTartDateTime = dateadd(month,-1,getutcdate())

--Temp table to customer details
	SELECT * INTO #CustomerData
	FROM BasicCustomerDataByAccount(@AccountId)

Select * from
(
SELECT
	Customer.*
	,convert(smalldatetime,dbo.fn_GetTimezoneTime(t.EffectiveTimestamp,ap.TimezoneId )) as [Credit Effective Date]
	,t.Id as [Transaction ID]
	,t.Amount * tt.ARBalanceMultiplier as [Credit Amount]
	,(ISNULL(cr.UnallocatedAmount, 0) * tt.ARBalanceMultiplier) AS [Remaining Unallocated Amount]
	,coalesce(cr.Reference,rc.Reference,'') as [Credit Reference]
	,cur.IsoName as Currency
	,ISNULL(cr.[Trigger], '') as [Trigger]
	,case when cr.TriggeringUserId is null then '' else (u.FirstName + ' ' + u.LastName) end as [Triggering User]
From
	[Transaction] t
	inner join AccountPreference ap	on t.AccountId = ap.Id
	inner join lookup.TransactionType tt on t.TransactionTypeId = tt.Id 
	inner join lookup.Currency cur on t.CurrencyId = cur.Id 
	left join Credit cr	on t.Id = cr.Id
	left join Debit rc on t.Id = rc.Id
	INNER JOIN #CustomerData Customer ON Customer.[Fusebill ID] = t.CustomerId
	left join [User] u on u.Id = cr.TriggeringUserId 
Where 
	t.AccountId = @AccountId 
	and t.EffectiveTimestamp >= @UTCSTartDateTime 
	and t.EffectiveTimestamp < @UTCEndDateTime 
	and t.CurrencyId = @CurrencyId 
	and t.transactionTypeId in (17,18)
) Result

DROP TABLE #CustomerData

GO

