 
 
CREATE PROC [dbo].[usp_InsertSubscriptionProductPriceRange]

	@SubscriptionProductId bigint,
	@Min decimal,
	@Max decimal,
	@Amount decimal
AS
SET NOCOUNT ON
	INSERT INTO [SubscriptionProductPriceRange] (
		[SubscriptionProductId],
		[Min],
		[Max],
		[Amount]
	)
	VALUES (
		@SubscriptionProductId,
		@Min,
		@Max,
		@Amount
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

