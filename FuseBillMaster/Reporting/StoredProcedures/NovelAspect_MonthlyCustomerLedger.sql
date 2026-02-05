
CREATE PROCEDURE [Reporting].[NovelAspect_MonthlyCustomerLedger]
	@AccountId BIGINT 
AS

declare @now datetime = getutcdate()

SET NOCOUNT ON
set transaction isolation level read uncommitted
DECLARE 
@StartDate datetime 
, @EndDate datetime = (select dateadd(day,-day(dateadd(month,1,convert(date,@now)))+1,dateadd(month,1,convert(date,@now))))
,@TimezoneId int

SELECT @StartDate = DATEADD(MONTH, -2, @EndDate)

select @EndDate = dbo.fn_GetUtcTime(@EndDate,TimezoneId)
,@StartDate = dbo.fn_GetUtcTime(@StartDate,TimezoneId)
,@TimezoneId = TimezoneId
from AccountPreference 
where Id = @AccountId

DECLARE @sql NVARCHAR(MAX)
	,@pivotColumns NVARCHAR(MAX) 

select @pivotColumns =  '['+DATENAME(month,dateadd(month,-2,@EndDate)) +', ' + CONVERT(char(4),datepart(year,dateadd(month,-2,@EndDate))) + ']' + ', ' +'['+DATENAME(month,dateadd(month,-1,@EndDate)) +', ' + CONVERT(char(4),datepart(year,dateadd(month,-1,@EndDate))) + ']'

SET @sql =
N'
SELECT
	FusebillId
	,CompanyName
	,' + @pivotColumns + N'
FROM
(
SELECT
	c.Id as FusebillId
	,ISNULL(c.CompanyName,'''') as CompanyName
	,DateName(MONTH,t.EffectiveTimestamp) + '', '' + CONVERT(char(40), DATEPART(year,t.EffectiveTimestamp)) as MonthYear
	,SUM(clj.ArDebit) - SUM(clj.ArCredit) + SUM(clj.CashDebit) - SUM(clj.CashCredit) as Amount
FROM Customer c
INNER JOIN [Transaction] t ON c.Id = t.CustomerId
INNER JOIN Lookup.TransactionType tt ON tt.Id = t.TransactionTypeId
INNER JOIN vw_CustomerLedgerJournal clj ON t.Id = clj.TransactionId
WHERE c.AccountId = ' + CONVERT(NVARCHAR(255),@AccountId) + N'
AND t.EffectiveTimestamp >= ''' + CONVERT(NVARCHAR(255),@StartDate) + N'''
AND t.EffectiveTimestamp < ''' + CONVERT(NVARCHAR(255),@EndDate) + N'''
AND tt.ARBalanceMultiplier <> 0
GROUP BY 
	c.Id
	,c.CompanyName
	,DateName(MONTH,t.EffectiveTimestamp) + '', '' + CONVERT(char(40), DATEPART(year,t.EffectiveTimestamp))
) data
pivot
(
	sum(Amount) for MonthYear IN (' + @pivotColumns + N')
) d
'
exec sp_executesql @sql

GO

