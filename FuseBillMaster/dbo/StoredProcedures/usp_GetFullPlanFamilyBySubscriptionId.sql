
CREATE   PROCEDURE [dbo].[usp_GetFullPlanFamilyBySubscriptionId]
	@subscriptionIds nvarchar(max),
	@AccountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @subscriptions table
	(
		SubscriptionId bigint
	)

	INSERT INTO @subscriptions (SubscriptionId)
	select Data from dbo.Split (@subscriptionIds,'|') as s
	inner join subscription on s.Data = subscription.Id
	inner join customer on customer.AccountId = @AccountId and customer.Id = subscription.customerId
	

	declare @frequencies table
	(
		FrequencyId bigint
	)
	INSERT INTO @frequencies (FrequencyId)
	SELECT 
		sub.PlanFrequencyId 
	FROM 
		Subscription sub
		inner join @subscriptions as tempSubIds on tempSubIds.SubscriptionId = sub.Id


	DECLARE @destiniationFrequencies TABLE
	(
		DestinationFrequency bigint
	)
	INSERT INTO 
		@destiniationFrequencies
	SELECT 
		relationship.DestinationPlanFrequencyId
	FROM 
		PlanFamilyRelationship relationship
		inner join @frequencies as freq on freq.FrequencyId = relationship.SourcePlanFrequencyId

--	select * from @destiniationFrequencies

	DECLARE @planRevisionIds TABLE
	(
		PlanRevision bigint
	)
	INSERT INTO @planRevisionIds
	SELECT freq.PlanRevisionId
	FROM PlanFrequency freq
	inner join @destiniationFrequencies destf on destf.DestinationFrequency = freq.Id

--	select * from @planRevisionIds

	DECLARE @planIds TABLE
	(
		PlanId bigint
	)
	INSERT INTO @planIds
	SELECT revision.PlanId FROM PlanRevision revision
	inner join @planRevisionIds prev on prev.PlanRevision = revision.Id

--	select * from @planIds


	DECLARE @planFamilyPlans TABLE
	(
		PlanFamilyPlans bigint,
		PlanFamilyId bigint
	)
	INSERT INTO @planFamilyPlans
	SELECT pfp.Id, pfp.PlanFamilyId FROM PlanFamilyPlan pfp
	inner join @planIds pid on pid.PlanId = pfp.PlanId

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
	inner join @planFamilyPlans pfp on pfp.PlanFamilyId = pf.Id

	--Get plan family plans
	SELECT pfp.* FROM PlanFamilyPlan pfp
	inner join @planIds pid on pid.PlanId = pfp.PlanId

	--Get plan 
	SELECT p.*, p.StatusId as [Status] FROM [Plan] p
	INNER JOIN @planIds temp ON temp.PlanId = p.Id
	WHERE p.IsDeleted = 0

	--Get plan revision
	SELECT pr.* FROM PlanRevision pr
	INNER JOIN @planIds temp ON pr.PlanId = temp.PlanId
	AND pr.IsActive = 1

	--Get plan frequency
	SELECT prf.*, prf.StatusId as [Status] FROM PlanFrequency prf
	INNER JOIN @destiniationFrequencies temp ON prf.Id = temp.DestinationFrequency
	INNER JOIN PlanRevision pr ON pr.Id = prf.PlanRevisionId
	INNER JOIN [Plan] p ON p.Id = pr.PlanId 
		AND pr.IsActive = 1
	where p.AccountId = @AccountId
	AND p.IsDeleted = 0
--	INNER JOIN PlanFamilyPlan pfp ON p.Id = pfp.PlanId

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
		inner join @frequencies freq on freq.FrequencyId = rel.SourcePlanFrequencyId

	SELECT
		*
	FROM CouponCode cc
	INNER JOIN PlanFamilyRelationship rel ON rel.CouponCodeId = cc.Id
	inner join @frequencies freq on freq.FrequencyId = rel.SourcePlanFrequencyId

	-- Get hosted page relationship customization
	SELECT
		hp.*
		, hp.MigrationTimingId as MigrationTiming
	FROM HostedPagePlanFamilyRelationship hp
	INNER JOIN HostedPage h ON h.Id = hp.HostedPageId AND h.HostedPageStatusId = 2
	INNER JOIN PlanFamilyRelationship rel ON rel.Id = hp.PlanFamilyRelationshipId
	inner join @frequencies freq on freq.FrequencyId = rel.SourcePlanFrequencyId
	where hp.AvailableOnSSP = 1

	-- Get hosted page relationship customization v2
	SELECT
		hp.*
		, hp.MigrationTimingId as MigrationTiming
	FROM [dbo].[HostedPageManagedSectionMigration] hp
	INNER JOIN [dbo].[HostedPageManagedSelfServicePortal] hpm on hpm.Id = hp.HostedPageManagedSelfServicePortalId
	INNER JOIN HostedPage h ON h.Id = hpm.HostedPageId AND h.HostedPageStatusId = 2
	INNER JOIN PlanFamilyRelationship rel ON rel.Id = hp.PlanFamilyRelationshipId
	inner join @frequencies freq on freq.FrequencyId = rel.SourcePlanFrequencyId
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
	  ,pfrm.[PriceOverrideOptionId] as [PriceOverrideOption]
	  ,pfrm.CustomFieldsOptionId
      ,pfrm.[ScheduledDateOptionId] as [ScheduledDateOption]
      ,pfrm.[CustomFieldsOptionId] as [CustomFieldsOption]
  FROM [dbo].[PlanFamilyRelationshipMapping] pfrm
  inner join PlanFamilyRelationship pfr on pfr.Id = pfrm.PlanFamilyRelationshipId
  inner join @frequencies freq on freq.FrequencyId = pfr.SourcePlanFrequencyId

  --Get the products which relate to each mapping 

  Select 
	pp.*,
	pp.ResetTypeId as [ResetType],
	pp.StatusId as [Status]
  from PlanProduct pp
  inner join [dbo].[PlanFamilyRelationshipMapping] pfrm on pfrm.SourcePlanProductId = pp.Id
  inner join PlanFamilyRelationship pfr on pfr.Id = pfrm.PlanFamilyRelationshipId
  inner join @frequencies freq on freq.FrequencyId = pfr.SourcePlanFrequencyId

  Select 
	pp.*,
	pp.ResetTypeId as [ResetType],
	pp.StatusId as [Status]
  from PlanProduct pp
  inner join [dbo].[PlanFamilyRelationshipMapping] pfrm on pfrm.DestinationPlanProductId = pp.Id
  inner join PlanFamilyRelationship pfr on pfr.Id = pfrm.PlanFamilyRelationshipId
  inner join @frequencies freq on freq.FrequencyId = pfr.SourcePlanFrequencyId
  
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

