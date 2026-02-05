
CREATE PROCEDURE [dbo].[usp_GetSubscriptionsForBillingPeriod]
	@BillingPeriodDefinitionId BIGINT
	,@ExcludeIds IDList READONLY
	,@CustomerId BIGINT
AS
BEGIN
	SELECT
		s.*
		,s.StatusId as [Status]
		,s.IntervalId as Interval
	FROM Subscription s
	LEFT JOIN @ExcludeIds e ON e.Id = s.Id
	WHERE s.BillingPeriodDefinitionId = @BillingPeriodDefinitionId
	AND s.CustomerId = @CustomerId
	AND e.Id IS NULL

END

GO

