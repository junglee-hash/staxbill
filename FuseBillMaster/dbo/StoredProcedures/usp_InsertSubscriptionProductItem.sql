 
 
CREATE PROC [dbo].[usp_InsertSubscriptionProductItem]

	@SubscriptionProductId bigint,
	@Id bigint
AS
SET NOCOUNT ON
	INSERT INTO [SubscriptionProductItem] (
		[SubscriptionProductId],
		[Id]
	)
	VALUES (
		@SubscriptionProductId,
		@Id
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

