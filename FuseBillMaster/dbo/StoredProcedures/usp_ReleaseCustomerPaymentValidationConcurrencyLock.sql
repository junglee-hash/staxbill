
CREATE PROCEDURE dbo.usp_ReleaseCustomerPaymentValidationConcurrencyLock
--DECLARE
@CustomerId BIGINT
AS

SET NOCOUNT ON

BEGIN TRANSACTION

DELETE FROM PaymentMethodValidationConcurrencyLock
WHERE ID = @CustomerId

COMMIT TRANSACTION

Select @@ROWCOUNT AS releasedRowCount

GO

