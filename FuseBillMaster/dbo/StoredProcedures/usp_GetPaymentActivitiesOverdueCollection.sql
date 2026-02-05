
CREATE    PROCEDURE [dbo].[usp_GetPaymentActivitiesOverdueCollection]
	-- Add the parameters for the stored procedure here
	@CustomerId BIGINT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--it is not always the case that we start with attempt 0
	DECLARE @lowestAttemptNumber BIT = (
			SELECT 
			CASE WHEN MIN(AttemptNumber) = 0 THEN 0 ELSE 1  END
			FROM PaymentActivityJournal 
			WHERE CustomerId = @CustomerId 
			AND PaymentTypeId = 2 
			AND PaymentPlatformCode IS NOT NULL
	)

	DECLARE @statusTimestamp DATETIME = (
			SELECT
			LastAccountStatusJournalTimestamp
			FROM customer
			Where Id = @CustomerId
	)

	SELECT 
		paj.*
		, paj.PaymentActivityStatusId AS PaymentActivityStatus
		, paj.PaymentMethodTypeId AS PaymentMethodType
		, paj.PaymentSourceId AS PaymentSource
		, paj.PaymentTypeId AS PaymentType
		, paj.SettlementStatusId AS SettlementStatus
		, paj.DisputeStatusId AS DisputeStatus
	FROM PaymentActivityJournal paj
	WHERE 
		paj.CustomerId = @CustomerId
		AND paj.Id >= (SELECT MAX(id) 
						FROM PaymentActivityJournal 
						WHERE CustomerId = @CustomerId 
						AND AttemptNumber = @lowestAttemptNumber 
						AND PaymentTypeId = 2 
						AND PaymentPlatformCode IS NOT NULL
						AND CreatedTimestamp > @statusTimestamp
						)
		AND paj.PaymentTypeId = 2
	ORDER BY id DESC
END

GO

