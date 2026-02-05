CREATE PROCEDURE [Reporting].[NovelAspect_ResellerCharges]
	@AccountId BIGINT
	,@StartDate DATETIME
	,@EndDate DATETIME
AS

DECLARE @TimezoneId int
	,@Padding char(100) ='                    '
	,@GLCodeFilter nvarchar(25) = 'Lease'
	
/* 01 Get the start of the end date in UTC */
select @EndDate = CONVERT(date,@EndDate)
select @StartDate = CONVERT(date,@StartDate)

/* 02 Detemine the start date */


/* 03 Convert dates to the UTC version for the account timezone */

select @EndDate = dbo.fn_GetUtcTime(@EndDate,TimezoneId)
,@StartDate = dbo.fn_GetUtcTime(@StartDate,TimezoneId)
,@TimezoneId = TimezoneId
from AccountPreference 
where Id = @AccountId

SELECT
	CASE WHEN CompanyName IS NULL THEN '' ELSE Name END as 'Parent Account/Reseller'
	,CASE WHEN Name IS NULL THEN 'Grand Total' ELSE COALESCE(CompanyName, @Padding + 'Total') END as 'Client of the Reseller (linked via Reseller code in tracking)'
	,SUM(Amount * ARBalanceMultiplier) as TotalCharged
	,CONVERT(decimal(18,2), SUM(Amount * ARBalanceMultiplier) * 0.10)  as 'Commission (10%)'
FROM
(
SELECT
	c.CompanyName
	,stc.Name
	,t.Amount
	,tt.ARBalanceMultiplier
FROM [Transaction] t
INNER JOIN Customer c ON c.Id = t.CustomerId
INNER JOIN CustomerReference cr ON cr.Id = c.Id
INNER JOIN SalesTrackingCode stc ON stc.Id = cr.SalesTrackingCode1Id
INNER JOIN Lookup.TransactionType tt ON tt.Id = t.TransactionTypeId
INNER JOIN Charge ch ON t.Id = ch.Id
LEFT JOIN GLCode glc ON glc.Id = ch.GLCodeId 
WHERE c.AccountId = @AccountId
	AND t.EffectiveTimestamp >= @StartDate
	AND t.EffectiveTimestamp < @EndDate
	AND ISNULL(glc.Code, '') <> @GLCodeFilter

UNION ALL

SELECT
	c.CompanyName
	,stc.Name
	,t.Amount
	,tt.ARBalanceMultiplier
FROM [Transaction] t
INNER JOIN Customer c ON c.Id = t.CustomerId
INNER JOIN CustomerReference cr ON cr.Id = c.Id
INNER JOIN SalesTrackingCode stc ON stc.Id = cr.SalesTrackingCode1Id
INNER JOIN Lookup.TransactionType tt ON tt.Id = t.TransactionTypeId
INNER JOIN ReverseCharge rch ON rch.Id = t.Id
INNER JOIN Charge och ON rch.OriginalChargeId = och.Id
LEFT JOIN GLCode glc ON glc.Id = och.GLCodeId
WHERE c.AccountId = @AccountId
	AND t.EffectiveTimestamp >= @StartDate
	AND t.EffectiveTimestamp < @EndDate
	AND ISNULL(glc.Code, '') <> @GLCodeFilter
) data
GROUP BY ROLLUP(
	Name
	,CompanyName
)

GO

