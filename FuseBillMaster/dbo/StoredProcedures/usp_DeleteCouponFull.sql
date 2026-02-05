
CREATE PROC [dbo].[usp_DeleteCouponFull]
	@Id BIGINT
AS

SET NOCOUNT ON;
	BEGIN

	SELECT CouponEligibilityId INTO #Eligibilities FROM CouponDiscount WHERE CouponId = @Id
	DELETE FROM CouponDiscount WHERE [CouponId] = @Id
	DELETE FROM CouponEligibility WHERE [Id] in (SELECT CouponEligibilityId FROM #Eligibilities)
	DROP TABLE #Eligibilities
	DELETE FROM CouponCode WHERE [CouponId] = @Id
	DELETE FROM CouponPlanProduct WHERE [CouponPlanId] in (SELECT Id FROM CouponPlan WHERE CouponId = @Id)
	DELETE FROM CouponPlan WHERE [CouponId] = @Id
	DELETE FROM Coupon WHERE [Id] = @Id
	
	END
SET NOCOUNT OFF;

GO

