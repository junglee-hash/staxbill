
CREATE   PROCEDURE [dbo].[usp_GetFullPlanFamiliesByPlanId]
	@PlanId bigint,
	@AccountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @planFamilies TABLE
	(
		PlanFamilyId bigint
	)

	INSERT INTO @planFamilies
	SELECT pf.Id FROM PlanFamily pf
	INNER JOIN PlanFamilyPlan pfp ON pf.Id = pfp.PlanFamilyId
		AND pfp.PlanId = @PlanId
		AND pf.AccountId = @AccountId

	--Get plan family
	select distinct 
		pf.Id,
		pf.AccountId,
		pf.ModifiedTimestamp,
		pf.CreatedTimestamp,
		pf.Code,
		pf.Name,
		pf.[Description],
		pf.EarningOptionId as EarningOption,
		pf.NameOverrideOptionId as NameOverrideOption,
		pf.DescriptionOverrideOptionId as DescriptionOverrideOption,
		pf.ReferenceOptionId as ReferenceOption,
		pf.ExpiryOptionId as ExpiryOption,
		pf.CustomFieldsOptionId,
		pf.ContractStartOptionId as ContractStartOption,
		pf.ContractEndOptionId as ContractEndOption 
	from PlanFamily pf
	INNER JOIN @planFamilies temp ON pf.Id = temp.PlanFamilyId

	SELECT pfp.* FROM PlanFamilyPlan pfp
	INNER JOIN @planFamilies temp ON pfp.PlanFamilyId = temp.PlanFamilyId

	SELECT p.*, p.StatusId as [Status] FROM [Plan] p
	where p.AccountId = @AccountId
	AND p.IsDeleted = 0

	SELECT pr.* FROM PlanRevision pr
	INNER JOIN [Plan] p ON p.Id = pr.PlanId 
		AND pr.IsActive = 1
	where p.AccountId = @AccountId
	AND p.IsDeleted = 0

	SELECT prf.*, prf.StatusId as [Status] FROM PlanFrequency prf
	INNER JOIN PlanRevision pr ON pr.Id = prf.PlanRevisionId
	INNER JOIN [Plan] p ON p.Id = pr.PlanId 
		AND pr.IsActive = 1
	where p.AccountId = @AccountId
	AND p.IsDeleted = 0

	--Get plan family Relationships
	SELECT 
		rel.*,
		rel.RelationshipMigrationTypeId as RelationshipMigrationType,
		rel.EarningOptionId as EarningOption,
		rel.NameOverrideOptionId as NameOverrideOption,
		rel.DescriptionOverrideOptionId as DescriptionOverrideOption,
		rel.ReferenceOptionId as ReferenceOption,
		rel.ExpiryOptionId as ExpiryOption,
		rel.ContractStartOptionId as ContractStartOption,
		rel.ContractEndOptionId as ContractEndOption
	FROM 
		PlanFamilyRelationship rel
		inner join @planFamilies pft on pft.PlanFamilyId = rel.PlanFamilyId
	-- Get the plan family relationship mappings

	SELECT
		*
	FROM CouponCode cc
	INNER JOIN PlanFamilyRelationship rel ON rel.CouponCodeId = cc.Id
	inner join @planFamilies pft on pft.PlanFamilyId = rel.PlanFamilyId

	SELECT
	   pfrm.*
      ,pfrm.[NameOverrideOptionId] as [NameOverrideOption]
      ,pfrm.[DescriptionOverrideOptionId] as [DescriptionOverrideOption]
      ,pfrm.[QuantityOptionId] as [QuantityOption]
      ,pfrm.[UpliftOptionId] as [UpliftOption]
      ,pfrm.[InclusionOptionId] as [InclusionOption]
      ,pfrm.[DiscountOptionId] as [DiscountOption]
      ,pfrm.[ExpiryOptionId] as [ExpiryOption]
	  ,pfrm.CustomFieldsOptionId
      ,pfrm.[ScheduledDateOptionId] as [ScheduledDateOption]
      ,pfrm.[CustomFieldsOptionId] as [CustomFieldsOption]
	  ,pfrm.PriceOverrideOptionId as [PriceOverrideOption]
  FROM [dbo].[PlanFamilyRelationshipMapping] pfrm
  inner join PlanFamilyRelationship pfr on pfr.Id = pfrm.PlanFamilyRelationshipId
  inner join @planFamilies pft on pft.PlanFamilyId = pfr.PlanFamilyId

  --Get the products which relate to each mapping 

  Select 
	pp.*,
	pp.ResetTypeId as [ResetType],
	pp.StatusId as [Status]
  from PlanProduct pp
  inner join [dbo].[PlanFamilyRelationshipMapping] pfrm on pfrm.SourcePlanProductId = pp.Id
  inner join PlanFamilyRelationship pfr on pfr.Id = pfrm.PlanFamilyRelationshipId
  inner join @planFamilies pft on pft.PlanFamilyId = pfr.PlanFamilyId

  Select 
	pp.*,
	pp.ResetTypeId as [ResetType],
	pp.StatusId as [Status]
  from PlanProduct pp
  inner join [dbo].[PlanFamilyRelationshipMapping] pfrm on pfrm.DestinationPlanProductId = pp.Id
  inner join PlanFamilyRelationship pfr on pfr.Id = pfrm.PlanFamilyRelationshipId
  inner join @planFamilies pft on pft.PlanFamilyId = pfr.PlanFamilyId
  
	SELECT pfk.[Id], pfk.[CreatedTimestamp]  
	FROM [dbo].[PlanFrequencyKey] pfk  
	INNER JOIN [dbo].[PlanFrequency] pf ON pfk.Id = pf.PlanFrequencyUniqueId  
	INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId  
	INNER JOIN [Plan] p ON pr.PlanId = p.Id
	WHERE p.AccountId = @AccountId
	AND p.IsDeleted = 0

  SELECT
    pfcc.*
	FROM [dbo].[PlanFrequencyCouponCode] pfcc
	INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcc.PlanFrequencyUniqueId
	INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId
	INNER JOIN [Plan] p ON pr.PlanId = p.Id
	WHERE p.AccountId = @AccountId
	AND p.IsDeleted = 0

SELECT cc.* 
	FROM CouponCode cc
	INNER JOIN [PlanFrequencyCouponCode] pfcc ON cc.Id = pfcc.CouponCodeId
	INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcc.PlanFrequencyUniqueId  
	INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId
	INNER JOIN [Plan] p ON pr.PlanId = p.Id
	WHERE p.AccountId = @AccountId
	AND p.IsDeleted = 0

	SELECT c.*, c.StatusId as [Status]
	FROM Coupon c
	INNER JOIN CouponCode cc ON c.Id = cc.CouponId
	INNER JOIN [PlanFrequencyCouponCode] pfcc ON cc.Id = pfcc.CouponCodeId
	INNER JOIN [dbo].[PlanFrequency] pf ON pf.PlanFrequencyUniqueId = pfcc.PlanFrequencyUniqueId  
	INNER JOIN [dbo].[PlanRevision] pr ON pr.Id = pf.PlanRevisionId
	INNER JOIN [Plan] p ON pr.PlanId = p.Id
	WHERE p.AccountId = @AccountId
	AND p.IsDeleted = 0

  END

GO

