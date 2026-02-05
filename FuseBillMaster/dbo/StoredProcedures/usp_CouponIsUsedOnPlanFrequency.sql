
CREATE   PROCEDURE [dbo].[usp_CouponIsUsedOnPlanFrequency]
	@CouponId bigint
	, @PlanIds IDList readonly
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT p.*, p.StatusId as [Status]
	FROM PlanFrequencyCouponCode pfcc
	INNER JOIN CouponCode cc ON cc.Id = pfcc.CouponCodeId
		AND cc.CouponId = @CouponId
	INNER JOIN PlanFrequency pf ON pf.PlanFrequencyUniqueId = pfcc.PlanFrequencyUniqueId
	INNER JOIN PlanRevision pr ON pr.Id = pf.PlanRevisionId
	INNER JOIN @PlanIds pp ON pp.Id = pr.PlanId
	INNER JOIN [Plan] p ON p.Id = pp.Id
	WHERE p.IsDeleted = 0

END

GO

