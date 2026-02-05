
CREATE   PROCEDURE [dbo].[usp_GetFullPlanFamilyByPlanFamilyId]
	@PlanFamilyIds nvarchar(max),
	@AccountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @PlanFamiliesTemp table
	(
		PlanFamilyId bigint
	)

	INSERT INTO @PlanFamiliesTemp (PlanFamilyId)
	select Data from dbo.Split (@PlanFamilyIds,'|')
	INNER JOIN PlanFamily pf ON pf.Id = Data
	WHERE pf.AccountId = @AccountId

	SELECT 
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
	FROM PlanFamily pf
	inner join @PlanFamiliesTemp pft on pft.PlanFamilyId = pf.Id 

	SELECT pfp.* FROM PlanFamilyPlan pfp
	INNER JOIN dbo.[plan] p on pfp.PlanId = p.Id
	inner join @PlanFamiliesTemp pft on pft.PlanFamilyId = pfp.PlanFamilyId
	WHERE p.IsDeleted = 0

	SELECT p.*, p.StatusId as [Status] FROM [Plan] p
	where p.AccountId = @AccountId
--	INNER JOIN PlanFamilyPlan pfp ON p.Id = pfp.PlanId
--	inner join @PlanFamiliesTemp pft on pft.PlanFamilyId = pfp.PlanFamilyId

	SELECT pr.* FROM PlanRevision pr
	INNER JOIN [Plan] p ON p.Id = pr.PlanId 
		AND pr.IsActive = 1
	where p.AccountId = @AccountId
	AND p.IsDeleted = 0
--	INNER JOIN PlanFamilyPlan pfp ON p.Id = pfp.PlanId
--	inner join @PlanFamiliesTemp pft on pft.PlanFamilyId = pfp.PlanFamilyId

	SELECT prf.*, prf.StatusId as [Status] FROM PlanFrequency prf
	INNER JOIN PlanRevision pr ON pr.Id = prf.PlanRevisionId
	INNER JOIN [Plan] p ON p.Id = pr.PlanId 
		AND pr.IsActive = 1
	where p.AccountId = @AccountId
	AND p.IsDeleted = 0
--	INNER JOIN PlanFamilyPlan pfp ON p.Id = pfp.PlanId
--	inner join @PlanFamiliesTemp pft on pft.PlanFamilyId = pfp.PlanFamilyId 

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
		inner join @PlanFamiliesTemp pft on pft.PlanFamilyId = rel.PlanFamilyId

	SELECT
		*
	FROM CouponCode cc
	INNER JOIN PlanFamilyRelationship rel ON rel.CouponCodeId = cc.Id
	inner join @planFamiliesTemp pft on pft.PlanFamilyId = rel.PlanFamilyId


	-- Get hosted page relationship customization
	SELECT
		hp.*
		, hp.MigrationTimingId as MigrationTiming
	FROM HostedPagePlanFamilyRelationship hp
	INNER JOIN HostedPage h ON h.Id = hp.HostedPageId AND h.HostedPageStatusId = 2
	INNER JOIN PlanFamilyRelationship rel ON rel.Id = hp.PlanFamilyRelationshipId
	inner join @PlanFamiliesTemp pft on pft.PlanFamilyId = rel.PlanFamilyId
	where hp.AvailableOnSSP = 1

	-- Get hosted page relationship customization v2
	SELECT
		hp.*
		, hp.MigrationTimingId as MigrationTiming
	FROM [dbo].[HostedPageManagedSectionMigration] hp
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] hpm on hpm.Id = hp.HostedPageManagedSelfServicePortalId
	INNER JOIN HostedPage h ON h.Id = hpm.HostedPageId AND h.HostedPageStatusId = 2
	INNER JOIN PlanFamilyRelationship rel ON rel.Id = hp.PlanFamilyRelationshipId
	inner join @PlanFamiliesTemp pft on pft.PlanFamilyId = rel.PlanFamilyId
	where hp.AvailableOnSSP = 1

	-- Get the plan family relationship mappings

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
	  ,pfrm.[PriceOverrideOptionId] as [PriceOverrideOption]
  FROM [dbo].[PlanFamilyRelationshipMapping] pfrm
  inner join PlanFamilyRelationship pfr on pfr.Id = pfrm.PlanFamilyRelationshipId
  inner join @PlanFamiliesTemp pft on pft.PlanFamilyId = pfr.PlanFamilyId

  --Get the products which relate to each mapping 

  Select 
	pp.*,
	pp.ResetTypeId as [ResetType],
	pp.StatusId as [Status]
  from PlanProduct pp
  inner join [dbo].[PlanFamilyRelationshipMapping] pfrm on pfrm.SourcePlanProductId = pp.Id
  inner join PlanFamilyRelationship pfr on pfr.Id = pfrm.PlanFamilyRelationshipId
  inner join @PlanFamiliesTemp pft on pft.PlanFamilyId = pfr.PlanFamilyId

  Select 
	pp.*,
	pp.ResetTypeId as [ResetType],
	pp.StatusId as [Status]
  from PlanProduct pp
  inner join [dbo].[PlanFamilyRelationshipMapping] pfrm on pfrm.DestinationPlanProductId = pp.Id
  inner join PlanFamilyRelationship pfr on pfr.Id = pfrm.PlanFamilyRelationshipId
  inner join @PlanFamiliesTemp pft on pft.PlanFamilyId = pfr.PlanFamilyId
  
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

