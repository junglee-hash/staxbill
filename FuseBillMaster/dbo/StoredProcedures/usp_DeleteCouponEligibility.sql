CREATE PROC [dbo].[usp_DeleteCouponEligibility]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CouponEligibility]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

