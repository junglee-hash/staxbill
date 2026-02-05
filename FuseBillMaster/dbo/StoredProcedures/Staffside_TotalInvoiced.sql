CREATE   PROCEDURE dbo.Staffside_TotalInvoiced
	@StartDate DATETIME = '2025-02-01'
	,@EndDate DATETIME = '2025-03-01'
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

;WITH ActiveAccounts AS
(
	SELECT
		Id
	FROM Account a
	WHERE 
	a.Live = 1
	AND a.TypeId = 1
	AND a.IncludeInAutomatedProcesses = 1
),
FilteredCustomers AS
(
	SELECT
		c.Id
		,lc.IsoName
	FROM Customer c
	INNER JOIN Lookup.Currency lc ON lc.Id = c.CurrencyId
	INNER JOIN ActiveAccounts a ON a.Id = c.AccountId
)
SELECT
	DATEPART(YEAR,i.EffectiveTimestamp) as [Year]
	,DATEPART(MONTH,i.EffectiveTimestamp) as [Month]
	,c.IsoName as Currency
	,SUM(i.SumOfCharges - i.SumOfDiscounts + i.SumOfTaxes) as AmountInvoiced
	,COUNT(*) as NumberOfInvoices
FROM Invoice i
INNER JOIN ActiveAccounts a ON a.Id = i.AccountId
INNER JOIN FilteredCustomers c ON c.Id = i.CustomerId
WHERE i.EffectiveTimestamp >= @StartDate
	AND i.EffectiveTimestamp < @EndDate
GROUP BY 
	DATEPART(YEAR,i.EffectiveTimestamp)
	,DATEPART(MONTH,i.EffectiveTimestamp)
	,c.IsoName
END

GO

