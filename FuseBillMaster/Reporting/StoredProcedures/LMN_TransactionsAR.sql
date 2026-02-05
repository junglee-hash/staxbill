
CREATE PROCEDURE [Reporting].[LMN_TransactionsAR]
@AccountId BIGINT = 21562
,@StartDate DATETIME
,@EndDate DATETIME 
,@CurrencyId BIGINT = 1
AS

set nocount on
set transaction isolation level snapshot


DECLARE @TimezoneId int
	

select @EndDate = dbo.fn_GetUtcTime(@EndDate,TimezoneId)
,@StartDate = dbo.fn_GetUtcTime(@StartDate,TimezoneId)
,@TimezoneId = TimezoneId
from AccountPreference 
where Id = @AccountId

SELECT
	dbo.fn_GetTimezoneTime(t.EffectiveTimestamp,@TimezoneId) AS TransactionTimestamp
	,c.Id AS FusebillId
	,ISNULL(c.CompanyName ,'') as CompanyName
	,ISNULL(a.State ,'') as State
	,ISNULL(a.Country,'') as Country
	,tt.Name as TransactionType
	,t.Id as TransactionNumber
	,COALESCE(ch.Name,r.Reference,cr.Reference,rc.Reference,pm.Reference,txr.Name,'') as Name
	,COALESCE(t.Description, txr.Description,'') as Description
	,t.Amount * tt.ARBalanceMultiplier as AccountsReceivable
	,CASE WHEN t.TransactionTypeId IN (3,4,5) THEN CONVERT(NVARCHAR, t.Amount * tt.ARBalanceMultiplier * -1) ELSE '' END as Cash
FROM [Transaction] t
INNER JOIN Customer c ON c.Id = t.CustomerId
INNER JOIN Lookup.TransactionType tt ON tt.Id = t.TransactionTypeId
LEFT JOIN [Address] a ON a.CustomerAddressPreferenceId = c.Id AND a.AddressTypeId = 1 --Biliing
LEFT JOIN Charge ch ON t.Id = ch.Id
LEFT JOIN Refund r ON t.Id = r.Id
LEFT JOIN Credit cr ON t.Id = cr.Id
LEFT JOIN ReverseCharge rc ON t.Id = rc.Id
LEFT JOIN Payment pm ON t.Id = pm.Id
LEFT JOIN Tax tx ON t.Id = tx.Id
LEFT JOIN TaxRule txr ON txr.Id = tx.TaxRuleId
WHERE t.AccountId = @AccountId
	AND t.CurrencyId = @CurrencyId
	AND t.EffectiveTimestamp >= @StartDate
	AND t.EffectiveTimestamp < @EndDate
	AND tt.ARBalanceMultiplier <> 0	
ORDER BY t.Id

GO

