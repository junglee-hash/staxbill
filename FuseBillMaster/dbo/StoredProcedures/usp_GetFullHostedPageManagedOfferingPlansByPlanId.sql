
CREATE PROCEDURE [dbo].usp_GetFullHostedPageManagedOfferingPlansByPlanId
	@planId BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT
		hpmop.*
	FROM [dbo].[HostedPageManagedOfferingPlan] hpmop
	WHERE hpmop.PlanId = @planId

	SELECT
		hpmopp.*
	FROM [dbo].[HostedPageManagedOfferingPlanProduct] hpmopp
	INNER JOIN [dbo].[HostedPageManagedOfferingPlan] hpmop on hpmop.Id = hpmopp.HostedPageManagedOfferingPlanId
	WHERE hpmop.PlanId = @planId

	SELECT
		hpmopf.*
	FROM [dbo].[HostedPageManagedOfferingPlanFrequency] hpmopf
	INNER JOIN [dbo].[HostedPageManagedOfferingPlan] hpmop on hpmop.Id = hpmopf.HostedPageManagedOfferingPlanId
	WHERE hpmop.PlanId = @planId

END

GO

