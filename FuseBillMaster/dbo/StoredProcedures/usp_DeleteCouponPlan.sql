CREATE PROC [dbo].[usp_DeleteCouponPlan]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CouponPlan]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

