CREATE   PROCEDURE [dbo].[usp_GetAccountForQuickBooksSyncExchangeRates]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		;WITH MultiCurrencyFusebillQBOAccounts AS (
		SELECT
			qb.Id as AccountId
		FROM AccountQuickBooksOnlineConfig qb
		INNER JOIN AccountFeatureConfiguration afc ON afc.Id = qb.Id AND afc.QuickBooksEnabled = 1
		INNER JOIN AccountCurrency ac ON ac.AccountId = qb.Id
		INNER JOIN Account a ON qb.Id = a.Id
		WHERE qb.StatusId = 2 --Activated
		AND a.IncludeInAutomatedProcesses = 1
		GROUP BY qb.Id
		HAVING COUNT(*) > 1
	)

	
	SELECT DISTINCT
		a.AccountId
		--,MaxCreatedTimestamp
	FROM MultiCurrencyFusebillQBOAccounts a
	LEFT OUTER JOIN (
			SELECT 
			AccountId
			,MAX(EffectiveTimestamp) AS MaxCreatedTimestamp
			FROM [AccountQuickBooksOnlineCurrencyExchange]
			GROUP BY AccountId) b
	ON a.AccountId = b.AccountId
	WHERE ISNULL(MaxCreatedTimestamp,'1950-01-01') < DATEADD(day, -1,GETUTCDATE())
				
END

GO

