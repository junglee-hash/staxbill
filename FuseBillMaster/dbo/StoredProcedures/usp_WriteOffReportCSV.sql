CREATE procedure [dbo].[usp_WriteOffReportCSV]
@AccountId bigint =10
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

SELECT
	Customer.*
	,convert(smalldatetime,dbo.fn_GetTimezoneTime(t.EffectiveTimestamp,ap.TimezoneId )) as [Write Off Effective Date]
	,t.Id as [Transaction ID]
	,i.InvoiceNumber as [Invoice ID]
	,t.Amount as [Write Off Amount]
	,cur.IsoName as Currency
	,wo.Reference as [Write Off Reference]
From
	[Transaction] t
	inner join AccountPreference ap
	on t.AccountId = ap.Id
	inner join lookup.TransactionType tt
	on t.TransactionTypeId = tt.Id 
	inner join lookup.Currency cur
	on t.CurrencyId = cur.Id 
	inner join WriteOff wo
	on t.Id = wo.Id
	inner join Invoice i
	on wo.InvoiceId = i.Id 
INNER JOIN #CustomerData Customer ON Customer.[Fusebill ID] = t.CustomerId
Where 
	t.AccountId = @AccountId 
	and t.EffectiveTimestamp >= @UTCSTartDateTime 
	and t.EffectiveTimestamp < @UTCEndDateTime 
	and t.TransactionTypeId = 10
	and t.CurrencyId = @CurrencyId 

DROP TABLE #CustomerData

GO

