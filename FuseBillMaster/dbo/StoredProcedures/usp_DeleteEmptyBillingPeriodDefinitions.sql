CREATE PROCEDURE [dbo].[usp_DeleteEmptyBillingPeriodDefinitions]
--Declare
	@CustomerId bigint
AS
--Select @CustomerId = 69319
BEGIN 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Find all Billing periods which are associated to a billing period definition which is also associated to either a subscription, draft invoice, or subscription product charge
	SELECT DISTINCT bpd.Id INTO #NotAllowedToDelete
		FROM BillingPeriod bp
		INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = bp.BillingPeriodDefinitionId
		WHERE bp.CustomerId = @CustomerId
		AND (bpd.ManuallyCreated = 1
			OR (
				EXISTS (
					SELECT
						*
					FROM Subscription s
					WHERE s.BillingPeriodDefinitionId = bpd.Id
				)
				OR EXISTS (
					SELECT
						*
					FROM DraftInvoice di
					WHERE di.BillingPeriodId = bp.Id
				)
				OR EXISTS (
					SELECT
						*
					FROM SubscriptionProductCharge spc
					WHERE spc.BillingPeriodId = bp.Id
				)
			) 
		)
	
	--Delete all billing periods which are not found in the CTE above
	DELETE 
		bp
	FROM BillingPeriod bp
	WHERE bp.CustomerId = @CustomerId
	AND NOT EXISTS 
	(
		SELECT
			*
		FROM #NotAllowedToDelete nad
		WHERE nad.Id = bp.BillingPeriodDefinitionId
	)

	--Delete all billing period schedules which are not found in the CTE above
	DELETE 
		bp
	FROM BillingPeriodPaymentSchedule bp
	INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = bp.BillingPeriodDefinitionId
	WHERE bpd.CustomerId = @CustomerId
	AND NOT EXISTS 
	(
		SELECT
			*
		FROM #NotAllowedToDelete nad
		WHERE nad.Id = bp.BillingPeriodDefinitionId
	)

	--We have deleted the BP at this point thus we do not need to use the above CTE to narrow the scope
	--The bp.Id is null should be sufficient to assert that we only delete billing period definitions which were already not found in the CTE above
	DELETE 
		bpd
	FROM BillingPeriodDefinition bpd
	WHERE bpd.CustomerId = @CustomerId
	AND bpd.ManuallyCreated = 0
	AND NOT EXISTS
	(
		SELECT
			*
		FROM BillingPeriod bp
		WHERE bp.BillingPeriodDefinitionId = bpd.Id
	)
	AND NOT EXISTS
	(
		SELECT
			*
		FROM Subscription s
		WHERE s.BillingPeriodDefinitionId = bpd.Id
	)

END

GO

