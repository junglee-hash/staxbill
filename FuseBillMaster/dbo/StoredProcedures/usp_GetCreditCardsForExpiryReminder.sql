CREATE   procedure [dbo].[usp_GetCreditCardsForExpiryReminder]
@MonthsBeforeExpiry int,
@RunDateTime datetime = null
AS

set nocount on
BEGIN TRY

if (@RunDateTime is null)
	SET @RunDateTime = GETUTCDATE()

SET @RunDateTime = dateadd(month,@MonthsBeforeExpiry, DATEFROMPARTS(YEAR(@RunDateTime), MONTH(@RunDateTime) , 1))

SELECT cc.Id
FROM CreditCard cc
INNER JOIN PaymentMethod pm ON pm.Id = cc.Id
INNER JOIN CustomerBillingSetting cbs ON pm.Id = cbs.DefaultPaymentMethodId
INNER JOIN Customer c ON c.Id = pm.CustomerId AND c.StatusId in (1,2,5) --Draft,Active, or Suspended
INNER JOIN Account a ON a.Id = c.AccountId
LEFT JOIN CreditCardExpiryActivity ccea ON cc.Id = ccea.CreditCardId AND ccea.MonthNotice = @MonthsBeforeExpiry
WHERE
		pm.PaymentMethodStatusId = 1
       AND DATEFROMPARTS(2000 + cc.ExpirationYear, cc.ExpirationMonth, 1) = @RunDateTime
	   -- weird data where month and year is 0
	   AND cc.ExpirationMonth > 0 AND cc.ExpirationMonth < 13
       AND ccea.Id IS NULL
	   AND c.IsDeleted = 0
	   AND a.IncludeInAutomatedProcesses = 1 
	   
END TRY

BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    SELECT 
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH
SET NOCOUNT OFF

GO

