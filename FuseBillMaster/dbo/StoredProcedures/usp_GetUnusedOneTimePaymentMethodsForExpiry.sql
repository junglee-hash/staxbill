
CREATE PROCEDURE [dbo].[usp_GetUnusedOneTimePaymentMethodsForExpiry]
	@date DATETIME
AS 

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
SET NOCOUNT, XACT_ABORT ON;


SELECT Id
FROM PaymentMethod
WHERE PaymentMethodStatusId = 2 -- deleted
AND PermittedForSingleUse = 1
AND CreatedTimestamp <= DATEADD(hour, -24, @date)

SET NOCOUNT, XACT_ABORT OFF;

GO

