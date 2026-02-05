CREATE PROC [dbo].[usp_DeleteCouponDiscount]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CouponDiscount]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

