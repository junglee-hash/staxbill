CREATE PROCEDURE [dbo].[usp_ReconciliationReport]
--DECLARE
@AccountId BIGINT --= 19
,@ReportStartDate DATETIME --= '2020-04-01 12:00:00 AM'
,@ReportEndDate DATETIME --= '2020-05-01 12:00:00 AM'
,@CurrencyId BIGINT --= 1
AS

/*TESTING
DECLARE
@AccountId BIGINT = 10
,@ReportStartDate DATETIME
,@ReportEndDate DATETIME
,@CurrencyId BIGINT = 1
--*/

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
--SET ARITHABORT ON	--This may have been used in the past to force appliciation connections as a method of preventing parameter sniffing

IF @ReportStartDate IS NULL OR @ReportEndDate IS NULL
	BEGIN
		SELECT @ReportEndDate = DATEADD(MONTH,-1,DATEADD(day,1,EOMONTH(GETUTCDATE())))
		SELECT @ReportStartDate = DATEADD(MONTH,-1,@ReportEndDate)
       
		SELECT @ReportEndDate = dbo.fn_GetTimezoneTime (@ReportEndDate,TimezoneId)			      
		,@ReportStartDate = dbo.fn_GetTimezoneTime (@ReportStartDate,TimezoneId)
		FROM AccountPreference 
		WHERE Id = @AccountId     
	END
--ELSE
--	BEGIN
--		SELECT @ReportEndDate = dbo.fn_GetUtcTime (@ReportEndDate,TimezoneId)			      
--		,@ReportStartDate = dbo.fn_GetUtcTime (@ReportStartDate,TimezoneId)
--		FROM AccountPreference 
--		WHERE Id = @AccountId     
--	END



;WITH CTE_RangeTransactions AS (
	SELECT *
	,CASE WHEN DebitsInPeriod - CreditsInPeriod > 0 THEN DebitsInPeriod - CreditsInPeriod ELSE NULL END AS NetDebits
	,CASE WHEN CreditsInPeriod - DebitsInPeriod >= 0 THEN CreditsInPeriod - DebitsInPeriod ELSE NULL END AS NetCredits
	FROM (
		SELECT 
			LedgerTypeId
			,SUM(CASE WHEN ttl.EntryType = 'Debit' THEN COALESCE(Amount,0) ELSE 0 END) AS DebitsInPeriod
			,SUM(CASE WHEN ttl.EntryType = 'Credit' THEN COALESCE(Amount,0) ELSE 0 END) AS CreditsInPeriod
		FROM [Transaction] t
		INNER JOIN [Customer] c ON t.CustomerId = c.Id 
		INNER JOIN Lookup.TransactionTypeLedger ttl ON ttl.TransactionTypeId = t.TransactionTypeId
		WHERE c.AccountId = @AccountId  
		AND t.EffectiveTimestamp >= @ReportStartDate 
		AND t.EffectiveTimestamp < @ReportEndDate
		AND t.CurrencyId = @CurrencyId
		GROUP BY
			   ttl.LedgerTypeId
		) t
	)

--Opening balance had previously been defeated with a "WHERE 1 = 2" predicate, so it is now completely excluded from the stored procedure
--Logic is left in place in the event this decision is reverse in future

--,CTE_OpeningBalance AS (
	--SELECT 
	--       LedgerTypeId
	--		,SUM(CASE WHEN ttl.EntryType = 'Debit' THEN COALESCE(Amount,0) ELSE 0 END - CASE WHEN ttl.EntryType = 'Credit' THEN COALESCE(Amount,0) ELSE 0 END) AS OpeningBalance
	--FROM [Transaction] t
	--INNER JOIN [Customer] c ON t.CustomerId = c.Id 
	--INNER JOIN Lookup.TransactionTypeLedger ttl ON ttl.TransactionTypeId = t.TransactionTypeId
	--WHERE c.AccountId = @AccountId
	--AND t.EffectiveTimestamp < @ReportStartDate
	--AND t.CurrencyId = @CurrencyId
	--GROUP BY
	--       ttl.LedgerTypeId
	--)

SELECT 
	Ledger
	,OpeningBalance
	,DebitsInPeriod
	,CreditsInPeriod
	,NetDebits
	,NetCredits
	,ClosingBalance
FROM (
	SELECT 
		[Name] as Ledger
		,CASE
				WHEN llt.Id = 2 THEN 1
				WHEN llt.Id = 1 THEN 2
				WHEN llt.Id = 5 THEN 3
				WHEN llt.Id = 4 THEN 4
				WHEN llt.Id = 3 THEN 5
				WHEN llt.Id = 6 THEN 6
				When llt.Id = 10 THEN 7
				WHEN llt.Id = 7 THEN 8
				WHEN llt.Id = 8 THEN 10
				When llt.Id = 9 THEN 9
				WHEN llt.Id = 11 THEN 11
		END as OrderBy
		--,COALESCE(ob.OpeningBalance,0) AS OpeningBalance
		,CONVERT(MONEY,0) AS OpeningBalance
		,rt.DebitsInPeriod as DebitsInPeriod
		,rt.CreditsInPeriod as CreditsInPeriod
		,NetDebits as NetDebits
		,NetCredits as NetCredits
		--,COALESCE(rt.ClosingBalance,0) + COALESCE(ob.OpeningBalance,0) AS ClosingBalance  
		,COALESCE(rt.DebitsInPeriod - rt.CreditsInPeriod,0) AS ClosingBalance
	FROM Lookup.LedgerType llt
	LEFT OUTER JOIN CTE_RangeTransactions rt
		ON llt.id = rt.LedgerTypeId
	--LEFT OUTER JOIN CTE_OpeningBalance ob
		--ON llt.id = ob.LedgerTypeId 
) Result
ORDER BY OrderBy

GO

