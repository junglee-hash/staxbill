
CREATE PROCEDURE [dbo].[usp_CustomerHasFailedStaxMigration]
	@customerId BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @hasFailedStaxMigration BIT = 0

    SELECT
		@hasFailedStaxMigration = CASE WHEN query.StaxCount = 0 AND query.OtherCount > 0 AND PrimaryGatewayFailureCount > 0 THEN 1 ELSE 0 END
	FROM(
		SELECT 
			SUM(CASE WHEN StoredInStax = 1 THEN 1 ELSE 0 END) AS StaxCount,
			SUM(CASE WHEN StoredInStax = 0 THEN 1 ELSE 0 END) AS OtherCount,
			SUM(CASE WHEN pj.PrimaryGatewayFailure IS NOT NULL THEN 1 ELSE 0 END) AS PrimaryGatewayFailureCount
		FROM PaymentMethod pm
		INNER JOIN PaymentActivityJournal pj ON pj.PaymentMethodId = pm.Id 		
		WHERE pm.CustomerId = @customerId
	) AS query


	SELECT @hasFailedStaxMigration
END

GO

