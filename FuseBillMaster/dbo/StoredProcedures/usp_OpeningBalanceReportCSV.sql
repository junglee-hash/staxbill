CREATE procedure [dbo].[usp_OpeningBalanceReportCSV]
@AccountId bigint 
,@UTCReportDateTime datetime 
,@CurrencyId bigint
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT

--Temp table to customer details
SELECT * INTO #CustomerData
FROM BasicCustomerDataByAccount(@AccountId)

SELECT
		Customer.*
		,t.Id as [Transaction ID]
	   ,convert(date,dbo.fn_GetTimezoneTime(t.EffectiveTimestamp,ap.TimezoneId)) as Date
       ,isnull(t.Description,'''') as Description
       ,cjl.OpeningBalanceDebit - cjl.OpeningBalanceCredit as OpeningBalanceAmount
FROM 
       [Transaction] t
       left join OpeningBalance ob
       on t.Id = ob.Id 
	   inner join vw_CustomerLedgerJournal cjl
	   on t.Id = cjl.TransactionId 
	   inner join AccountPreference ap
	   on t.AccountId = ap.Id
	   INNER JOIN #CustomerData Customer ON Customer.[Fusebill ID] = t.CustomerId
WHERE
       t.AccountId = @AccountId
       and t.EffectiveTimestamp < @UTCReportDateTime
       and t.CurrencyId = @CurrencyId
	   and t.TransactionTypeId in(16,19)

DROP TABLE #CustomerData

GO

