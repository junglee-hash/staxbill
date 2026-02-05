CREATE   PROCEDURE dbo.usp_GetSubscriptionIdsByCustomer
	@CustomerId BIGINT
	,@AccountId BIGINT
AS

--Make sure the customer exists
IF EXISTS(SELECT 1 FROM Customer WHERE Id = @CustomerId AND AccountId = @AccountId AND IsDeleted = 0)
BEGIN
	SELECT
		s.Id
	FROM Subscription s 
	WHERE s.CustomerId = @CustomerId
	AND s.IsDeleted = 0

	UNION 

	SELECT
		s.Id
	FROM BillingPeriodDefinition bpd
	INNER JOIN Subscription s ON bpd.Id = s.BillingPeriodDefinitionId
	WHERE bpd.CustomerId = @CustomerId
	AND s.IsDeleted = 0
END

GO

