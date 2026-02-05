CREATE PROC [dbo].[usp_DeleteCoupon]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Coupon]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

