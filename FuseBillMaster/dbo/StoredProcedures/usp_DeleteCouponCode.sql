CREATE PROC [dbo].[usp_DeleteCouponCode]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CouponCode]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

