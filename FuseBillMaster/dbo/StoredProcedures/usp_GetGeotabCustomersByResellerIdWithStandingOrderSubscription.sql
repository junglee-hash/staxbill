CREATE PROCEDURE [dbo].[usp_GetGeotabCustomersByResellerIdWithStandingOrderSubscription]

	@ResellerIds nvarchar(max),
	@AccountId bigint

AS

	SET XACT_ABORT, NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	--SET FMTONLY OFF

CREATE TABLE #Resellers (
	Id nvarchar(500)
)

INSERT INTO #Resellers
select Data from dbo.Split (@ResellerIds,'|')

SELECT ci.IntegrationId as ResellerId, ci.CustomerId
FROM CustomerIntegration ci
INNER JOIN #Resellers ON ci.CustomerIntegrationTypeId = 3 -- Geotab
	AND ci.IntegrationId = #Resellers.Id
INNER JOIN Customer c ON c.Id = ci.CustomerId
	AND c.AccountId = @AccountId
WHERE EXISTS (
	SELECT * 
	FROM Subscription s
	WHERE s.CustomerId = ci.CustomerId
		AND s.StatusId = 8 -- Standing order
		AND s.IsDeleted = 0
	)

DROP TABLE #Resellers

GO

