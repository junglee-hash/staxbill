CREATE   PROCEDURE [dbo].[usp_GetAccountForHistoricalQuickBooksSyncExchangeRates]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	;WITH FirstExchangeRate AS (
        SELECT
            AccountId
            ,MIN(EffectiveTimestamp) as ExchangeStartDate
        FROM AccountQuickBooksOnlineCurrencyExchange qbo
        GROUP BY AccountId 
    )
    SELECT
        c.AccountId as AccountId
        ,CASE WHEN MIN(c.QuickBooksSyncTimestamp) > acc.CreatedTimestamp 
            THEN MIN(c.QuickBooksSyncTimestamp)
            ELSE acc.CreatedTimestamp 
            END AS FromDate
        --,fer.ExchangeStartDate as ToDate
    FROM Customer c
    INNER JOIN FirstExchangeRate fer ON c.AccountId = fer.AccountId
    INNER JOIN Account acc on acc.Id = fer.AccountId
    WHERE 
		acc.IncludeInAutomatedProcesses = 1
		AND CASE WHEN c.QuickBooksSyncTimestamp > acc.CreatedTimestamp THEN c.QuickBooksSyncTimestamp
            ELSE acc.CreatedTimestamp END < fer.ExchangeStartDate and c.QuickBooksSyncTimestamp is not null
		AND 1=0
    GROUP BY c.AccountId,fer.ExchangeStartDate,acc.CreatedTimestamp

END

GO

