
CREATE     PROCEDURE [dbo].[usp_GetCountsOfEntitiesPreventingSoftCustomerDeletion]
@customerId BIGINT
AS
BEGIN
	DECLARE @TransactionCount INT
	DECLARE @InvalidSubscriptionCount INT
	DECLARE @InvalidPurchaseCount INT
	DECLARE @PaymentMethodCount INT

	SET @TransactionCount = ( 
		SELECT COUNT(Id) from dbo.[Transaction]
		WHERE customerId = @customerId
	)

	SET @InvalidSubscriptionCount = ( 
		SELECT COUNT(Id) from dbo.[Subscription]
		WHERE customerId = @customerId
		AND StatusId NOT IN (1,8) --draft and standing order
	)

	SET @InvalidPurchaseCount = ( 
		SELECT COUNT(Id) from dbo.[Purchase]
		WHERE customerId = @customerId
		AND StatusId <> 1 --draft
	)

	SET @PaymentMethodCount = ( 
		SELECT COUNT(Id) from dbo.[PaymentMethod]
		WHERE customerId = @customerId
		AND PaymentMethodStatusId <> 2 --deleted
	)

	SELECT 
	@TransactionCount AS TransactionCount,
	@InvalidSubscriptionCount AS InvalidSubscriptionCount,
	@InvalidPurchaseCount AS InvalidPurchaseCount,
	@PaymentMethodCount AS PaymentMethodCount

END

GO

