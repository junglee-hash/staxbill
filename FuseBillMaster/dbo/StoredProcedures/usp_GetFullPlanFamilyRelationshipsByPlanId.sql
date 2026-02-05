
CREATE PROCEDURE [dbo].[usp_GetFullPlanFamilyRelationshipsByPlanId]
	@PlanId bigint
	,@AccountId bigint
AS
BEGIN

select 
		pfr.*
		,pfr.RelationshipMigrationTypeId as RelationshipMigrationType
		,pfr.EarningOptionId as EarningOption
		,pfr.NameOverrideOptionId as NameOverrideOption
		,pfr.DescriptionOverrideOptionId as DescriptionOverrideOption
		,pfr.ReferenceOptionId as ReferenceOption
		,pfr.ExpiryOptionId as ExpiryOption
		,pfr.ContractStartOptionId as ContractStartOption
		,pfr.ContractEndOptionId as ContractEndOption
	from PlanFamilyRelationship pfr
	INNER JOIN PlanFamily pf ON pf.Id = pfr.PlanFamilyId
	INNER JOIN PlanFrequency src ON src.Id = pfr.SourcePlanFrequencyId
	INNER JOIN PlanRevision srcrev ON srcrev.Id = src.PlanRevisionId
	INNER JOIN PlanFrequency dst ON dst.Id = pfr.DestinationPlanFrequencyId
	INNER JOIN PlanRevision dstrev ON dstrev.Id = dst.PlanRevisionId
	WHERE pf.AccountId = @AccountId
		AND (srcrev.PlanId = @PlanId OR dstrev.PlanId = @PlanId)


END

GO

