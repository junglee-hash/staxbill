CREATE PROCEDURE [dbo].[Staffside_CatalogSummaryPlanFamilies]
	@AccountId BIGINT
AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT

SELECT
	pf.Id as PlanFamilyId
	,pf.Name as PlanFamilyName
	,pf.Code as PlanFamilyCode
	,pf.Description as PlanFamilyDescription
	,pf.CreatedTimestamp as PlanFamilyCreatedTimestamp
	,pf.ModifiedTimestamp as PlanFamilyModifiedTimestamp
	,CASE WHEN pfeo.Id = 1 THEN 'Earn All' ELSE pfeo.Name END as PlanFamilyEarningOption
	,pfmoName.Name as PlanFamilyNameOverride
	,pfmoDesc.Name as PlanFamilyDescriptinoOverride
	,pfmoRef.Name as PlanFamilyReferenceOverride
	,pfmoExp.Name as PlanFamilyExpiryOverride
	,pfmoCStrt.Name as PlanFamilyContractStartOverride
	,pfmoCEnd.Name as PlanFamilyContractEndOverride
	,pfr.Id as PlanFamilyRelationshipId
	,pfr.SourceLabel as SourcePlanFrequency
	,pfr.DestinationLabel as DestinationPlanFrequency
	,rmt.Name as MigrationType
	,pfr.CreatedTimestamp as PlanFamilyRelationshipCreatedTimestamp
	,pfr.ModifiedTimestamp as PlanFamilyRelationshipModifiedTimestamp
	,CASE WHEN pfreo.Id = 1 THEN 'Earn All' ELSE pfreo.Name END as PlanFamilyRelationshipEarningOption
	,pfrmoName.Name as PlanFamilyRelationshipNameOverride
	,pfrmoDesc.Name as PlanFamilyRelationshipDescriptinoOverride
	,pfrmoRef.Name as PlanFamilyRelationshipReferenceOverride
	,pfrmoExp.Name as PlanFamilyRelationshipExpiryOverride
	,pfrmoCStrt.Name as PlanFamilyRelationshipContractStartOverride
	,pfrmoCEnd.Name as PlanFamilyRelationshipContractEndOverride
	,srcpp.Name as SourcePlanProductName
	,srcpp.Code as SourcePlanProductCode
	,dstpp.Name as DestinationPlanProductName
	,dstpp.Code as DestinationPlanProductCode
	,pfrm.CreatedTimestamp as PlanFamilyRelationshipMappingCreatedTimestamp
	,pfrm.ModifiedTimestamp as PlanFamilyRelationshipMappingModifiedTimestamp
	,pmmoName.Name as PlanFamilyRelationshipMappingNameOverride
	,pmmoDesc.Name as PlanFamilyRelationshipMappingDescriptionOverride
	,pmmoQty.Name as PlanFamilyRelationshipMappingQuantityOverride
	,pmmoUp.Name as PlanFamilyRelationshipMappingUpliftOverride
	,pmmoIncl.Name as PlanFamilyRelationshipMappingInclusionOverride
	,pmmoDisc.Name as PlanFamilyRelationshipMappingDiscountOverride
	,pmmoExp.Name as PlanFamilyRelationshipMappingExpirationOverride
	,pmmoSchd.Name as PlanFamilyRelationshipMappingScheduledActivationOverride
	,pmmoCf.Name as PlanFamilyRelationshipMappingCustomFieldsOverride
FROM PlanFamilyRelationShipMapping pfrm
INNER JOIN PlanFamilyRelationship pfr ON pfr.Id = pfrm.PlanFamilyRelationshipId
INNER JOIN PlanFamily pf ON pf.Id = pfr.PlanFamilyId
INNER JOIN Lookup.RelationshipMigrationType rmt ON rmt.Id = pfr.RelationshipMigrationTypeId
INNER JOIN Lookup.PlanFamilyEarningOptions pfeo ON pfeo.Id = pf.EarningOptionId
INNER JOIN Lookup.PlanFamilyMigrationOptions pfmoName ON pfmoName.Id = pf.NameOverrideOptionId
INNER JOIN Lookup.PlanFamilyMigrationOptions pfmoDesc ON pfmoDesc.Id = pf.DescriptionOverrideOptionId
INNER JOIN Lookup.PlanFamilyMigrationOptions pfmoRef ON pfmoRef.Id = pf.ReferenceOptionId
INNER JOIN Lookup.PlanFamilyMigrationOptions pfmoExp ON pfmoExp.Id = pf.ExpiryOptionId
INNER JOIN Lookup.PlanFamilyMigrationOptions pfmoCStrt ON pfmoCStrt.Id = pf.ContractStartOptionId
INNER JOIN Lookup.PlanFamilyMigrationOptions pfmoCEnd ON pfmoCEnd.Id = pf.ContractEndOptionId
INNER JOIN Lookup.PlanFamilyEarningOptions pfreo ON pfreo.Id = pfr.EarningOptionId
INNER JOIN Lookup.PlanFamilyMigrationOptions pfrmoName ON pfrmoName.Id = pfr.NameOverrideOptionId
INNER JOIN Lookup.PlanFamilyMigrationOptions pfrmoDesc ON pfrmoDesc.Id = pfr.DescriptionOverrideOptionId
INNER JOIN Lookup.PlanFamilyMigrationOptions pfrmoRef ON pfrmoRef.Id = pfr.ReferenceOptionId
INNER JOIN Lookup.PlanFamilyMigrationOptions pfrmoExp ON pfrmoExp.Id = pfr.ExpiryOptionId
INNER JOIN Lookup.PlanFamilyMigrationOptions pfrmoCStrt ON pfrmoCStrt.Id = pfr.ContractStartOptionId
INNER JOIN Lookup.PlanFamilyMigrationOptions pfrmoCEnd ON pfrmoCEnd.Id = pfr.ContractEndOptionId
INNER JOIN Lookup.ProductMappingMigrationOption pmmoName ON pmmoName.Id = pfrm.NameOverrideOptionId
INNER JOIN Lookup.ProductMappingMigrationOption pmmoDesc ON pmmoDesc.Id = pfrm.DescriptionOverrideOptionId
INNER JOIN Lookup.ProductMappingMigrationOption pmmoQty ON pmmoQty.Id = pfrm.QuantityOptionId
INNER JOIN Lookup.ProductMappingMigrationOption pmmoUp ON pmmoUp.Id = pfrm.UpliftOptionId
INNER JOIN Lookup.InclusionMigrationOption pmmoIncl ON pmmoIncl.Id = pfrm.InclusionOptionId
INNER JOIN Lookup.ProductMappingMigrationOption pmmoDisc ON pmmoDisc.Id = pfrm.DiscountOptionId
INNER JOIN Lookup.ProductMappingMigrationOption pmmoExp ON pmmoExp.Id = pfrm.ExpiryOptionId
INNER JOIN Lookup.ProductMappingMigrationOption pmmoSchd ON pmmoSchd.Id = pfrm.ScheduledDateOptionId
INNER JOIN Lookup.ProductMappingMigrationOption pmmoCf ON pmmoCf.Id = pfrm.CustomFieldsOptionId
LEFT JOIN PlanProduct srcpp ON srcpp.Id = pfrm.SourcePlanProductId
LEFT JOIN PlanProduct dstpp ON dstpp.Id = pfrm.DestinationPlanProductId
WHERE pf.AccountId = @AccountId

GO

