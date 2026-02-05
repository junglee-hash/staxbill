CREATE PROC [dbo].[usp_DeleteCouponPlanProduct]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CouponPlanProduct]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

