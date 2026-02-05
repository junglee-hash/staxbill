
CREATE PROCEDURE dbo.usp_AttemptToLockCustomerPaymentValidations
--DECLARE
@CustomerId BIGINT,
@LockDurationSeconds BIGINT = 60,
@DateForTesting DATETIME NULL = NULL
AS

SET NOCOUNT ON

BEGIN TRANSACTION



DECLARE @WasUnlocked BIT
SET @WasUnlocked = 1;

IF NOT EXISTS(
	SELECT * FROM 
	PaymentMethodValidationConcurrencyLock WITH (XLOCK) 
	WHERE Id = @CustomerId 
)
	BEGIN
		INSERT INTO PaymentMethodValidationConcurrencyLock
			VALUES (@CustomerId, DATEADD(SECOND, @LockDurationSeconds, COALESCE(@DateForTesting, GETUTCDATE())))
			SET @WasUnlocked = 1
	END
ELSE 
	BEGIN
	UPDATE PaymentMethodValidationConcurrencyLock 
		SET UnlockTimestamp = DATEADD(SECOND, @LockDurationSeconds,  COALESCE(@DateForTesting, GETUTCDATE()))
	WHERE Id = @CustomerId AND UnlockTimestamp <  COALESCE(@DateForTesting, GETUTCDATE())
	
	SET @WasUnlocked = @@ROWCOUNT
END

COMMIT TRANSACTION

SELECT @WasUnlocked AS SuccessfullyLockedCustomer

GO

