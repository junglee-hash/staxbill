CREATE PROCEDURE [dbo].[usp_Widget_PaymentMethod]
	@AccountId BIGINT
	,@CurrencyId BIGINT
AS

DECLARE @AccountAutoCollect BIT
	,@TwoMonths SMALLDATETIME
	,@OneMonth SMALLDATETIME
	,@ThisMonth SMALLDATETIME

SELECT 
	@AccountAutoCollect = DefaultAutoCollect
FROM AccountBillingPreference
WHERE Id = @AccountId

SELECT 
	cbs.DefaultPaymentMethodId
	,COALESCE(cbs.AutoCollect, @AccountAutoCollect) as AutoCollect
INTO #Customers
FROM Customer c
INNER JOIN CustomerBillingSetting cbs ON c.Id = cbs.Id
WHERE c.AccountId = @AccountId	
	AND c.StatusId IN (2,4,5)
	AND c.CurrencyId = @CurrencyId

;WITH TodayInAccountTimezone AS (
SELECT
	DATEFROMPARTS(YEAR(dbo.fn_GetTimezoneTime(GETUTCDATE(),tz.Id)), MONTH(dbo.fn_GetTimezoneTime(GETUTCDATE(),tz.Id)), 1) as StartOfMonth
	, ap.Id as AccountId
	FROM AccountPreference ap
	INNER JOIN Lookup.Timezone tz ON tz.Id = ap.TimezoneId
	WHERE ap.Id = @AccountId
)
SELECT
	@TwoMonths = DATEADD(month, 2, StartOfMonth)
	,@OneMonth = DATEADD(month, 1, StartOfMonth)
	,@ThisMonth = DATEADD(month, 0, StartOfMonth)
FROM TodayInAccountTimezone

;WITH PaymentMethodStatuses AS (
	SELECT 
		CASE 
		WHEN cc.ExpirationMonth = 0 -- There is some bunked data from imports so treat invalid expiry as on file
		THEN 'PaymentMethodOnFile' 
		WHEN
			DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) >
				@TwoMonths -- Expiry is greater than 3 months
		THEN 'PaymentMethodOnFile' 
		WHEN 
			DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) =
				@TwoMonths -- Expiry is in 2 months
		THEN 'ExpireInTwoMonths'  
		WHEN 
			DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) =
				@OneMonth -- Expiry is in 1 month
		THEN 'ExpireInOneMonth'  
		WHEN 
			DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) =
				@ThisMonth -- Expiries this month
		THEN 'ExpiresThisMonth'  
		WHEN 
			DATEFROMPARTS(cc.ExpirationYear + 2000, cc.ExpirationMonth, 1) <
				@ThisMonth -- Expiry is in 2 months
		THEN 'Expired'
			END as PaymentMethodOnFile
	FROM #Customers c
	INNER JOIN PaymentMethod pm ON pm.Id = c.DefaultPaymentMethodId
	INNER JOIN CreditCard cc ON cc.Id = pm.Id
	WHERE c.DefaultPaymentMethodId IS NOT NULL
)
,NonDedupedResults AS (
	SELECT
		PaymentMethodOnFile
		,COUNT(*) as Count
	FROM PaymentMethodStatuses
	GROUP BY PaymentMethodOnFile
	UNION ALL
	SELECT
		'Missing' as PaymentMethodOnFile
		,COUNT(*) as Count
	FROM #Customers
	WHERE AutoCollect = 1
		AND DefaultPaymentMethodId IS NULL
	UNION ALL
	SELECT
		'PaymentMethodOnFile' as PaymentMethodOnFile
		,COUNT(*) as Count
	FROM #Customers c
	INNER JOIN PaymentMethod pm ON pm.Id = c.DefaultPaymentMethodId
	WHERE pm.PaymentMethodTypeId != 3
	UNION ALL
	SELECT 'Disabled' as PaymentMethodOnFile
		,COUNT(*) as Count
	FROM #Customers c
	INNER JOIN PaymentMethod pm ON pm.Id = c.DefaultPaymentMethodId
		AND pm.PaymentMethodStatusId = 3
)
SELECT
	PaymentMethodOnFile
	,SUM(r.Count) as Count
FROM NonDedupedResults r
GROUP BY PaymentMethodOnFile

DROP TABLE #Customers

GO

