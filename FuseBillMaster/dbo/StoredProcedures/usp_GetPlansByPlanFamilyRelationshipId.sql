
CREATE   PROCEDURE [dbo].[usp_GetPlansByPlanFamilyRelationshipId]
	@FamilyPlanRelationshipId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   select 
		p.*
		,p.StatusId as [Status]
	from PlanFamilyRelationship pfr
	join PlanFrequency pf on pf.Id = pfr.SourcePlanFrequencyId or pf.Id = pfr.DestinationPlanFrequencyId
	join PlanRevision pr on pr.Id = pf.PlanRevisionId
	join [Plan] p on pr.PlanId = p.Id
	where 
		pfr.id = @FamilyPlanRelationshipId
		AND p.IsDeleted = 0
END

GO

