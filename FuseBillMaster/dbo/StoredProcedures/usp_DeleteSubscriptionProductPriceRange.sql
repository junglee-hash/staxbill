CREATE PROC [dbo].[usp_DeleteSubscriptionProductPriceRange]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SubscriptionProductPriceRange]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

