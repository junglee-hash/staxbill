CREATE PROC [dbo].[usp_DeletePlanFull]
	@Id BIGINT
AS

SET NOCOUNT ON;
		IF EXISTS(
		SELECT
			*
		FROM 
			Subscription targetTable			
			INNER JOIN [Plan] p on p.Id = targetTable.PlanId
			WHERE p.Id = @Id
	)
	BEGIN
		RAISERROR (15600,-1,-1, 'Plan is associated with one or more subscriptions and can not be deleted.');
		RETURN 55555
	END

SET XACT_ABORT, NOCOUNT ON 
DECLARE @ERRORFLAG BIT = 0
	BEGIN TRY
	BEGIN

		DELETE TargetTable
		FROM HostedPageManagedOfferingPlanProduct TargetTable
		INNER JOIN HostedPageManagedOfferingPlan hpmop ON TargetTable.HostedPageManagedOfferingPlanId = hpmop.Id
		WHERE hpmop.PlanId = @Id

		DELETE TargetTable
		FROM HostedPageManagedOfferingPlanFrequency TargetTable
		INNER JOIN HostedPageManagedOfferingPlan hpmop ON TargetTable.HostedPageManagedOfferingPlanId = hpmop.Id
		WHERE hpmop.PlanId = @Id

		DELETE TargetTable
		FROM HostedPageManagedOfferingPlan TargetTable
		WHERE TargetTable.PlanId = @Id

		DELETE TargetTable
		FROM CouponPlanProduct TargetTable
		INNER JOIN CouponPlan cp ON TargetTable.CouponPlanId = cp.Id
		WHERE cp.PlanId = @Id

		DELETE TargetTable
		FROM CouponPlan TargetTable
		WHERE TargetTable.PlanId = @Id

		DELETE TargetTable  
		FROM PlanProductPriceUplift TargetTable  
		INNER JOIN PlanOrderToCashCycle poc ON TargetTable.PlanOrderToCashCycleId = poc.Id
		INNER JOIN PlanProduct pp on pp.Id = poc.PlanProductId
		INNER JOIN PlanRevision pr on pr.Id = pp.PlanRevisionId
		WHERE pr.PlanId = @Id

		DELETE TargetTable
		FROM PlanOrderToCashCycle TargetTable
		INNER JOIN PlanProduct pp ON TargetTable.PlanProductId = pp.Id
		INNER JOIN PlanRevision pr on pr.Id = pp.PlanRevisionId
		WHERE pr.PlanId = @Id

		DELETE TargetTable
		FROM PlanOrderToCashCycle TargetTable
		INNER JOIN PlanFrequency pf ON TargetTable.PlanFrequencyId = pf.Id
		INNER JOIN PlanRevision pr on pr.Id = pf.PlanRevisionId
		WHERE pr.PlanId = @Id

		DELETE TargetTable
		FROM PlanFamilyRelationshipMapping TargetTable
		INNER JOIN PlanProduct pp ON TargetTable.SourcePlanProductId = pp.Id
		INNER JOIN PlanRevision pr ON pr.Id = pp.PlanRevisionId
		WHERE pr.PlanId = @Id

		DELETE TargetTable
		FROM PlanFamilyRelationshipMapping TargetTable
		INNER JOIN PlanProduct pp ON TargetTable.DestinationPlanProductId = pp.Id
		INNER JOIN PlanRevision pr ON pr.Id = pp.PlanRevisionId
		WHERE pr.PlanId = @Id

		DELETE TargetTable
		FROM PlanFamilyRelationship TargetTable
		INNER JOIN PlanFrequency pf ON TargetTable.SourcePlanFrequencyId = pf.Id
		INNER JOIN PlanRevision pr ON pr.Id = pf.PlanRevisionId
		WHERE pr.PlanId = @Id

		DELETE TargetTable
		FROM PlanFamilyRelationship TargetTable
		INNER JOIN PlanFrequency pf ON TargetTable.DestinationPlanFrequencyId = pf.Id
		INNER JOIN PlanRevision pr ON pr.Id = pf.PlanRevisionId
		WHERE pr.PlanId = @Id

		CREATE TABLE #PlanProductKey (Id BIGINT PRIMARY KEY)

		INSERT INTO #PlanProductKey SELECT ppk.Id FROM PlanProductKey ppk
		INNER JOIN PlanProduct pp ON pp.PlanProductUniqueId = ppk.Id
		INNER JOIN PlanRevision pr ON pr.Id = pp.PlanRevisionId
		WHERE pr.PlanId = @Id

		CREATE TABLE #PlanFrequencyKey (Id BIGINT PRIMARY KEY)

		INSERT INTO #PlanFrequencyKey SELECT pfk.Id FROM PlanFrequencyKey pfk
		INNER JOIN PlanFrequency pf ON pf.PlanFrequencyUniqueId = pfk.Id
		INNER JOIN PlanRevision pr ON pr.Id = pf.PlanRevisionId
		WHERE pr.PlanId = @Id

		DELETE TargetTable
		FROM PlanFrequency TargetTable
		INNER JOIN PlanRevision pr ON TargetTable.PlanRevisionId = pr.Id
		Where pr.PlanId = @Id

		DELETE TargetTable
		FROM PlanFrequencyCustomField TargetTable
		INNER JOIN PlanFrequencyKey pfk ON pfk.Id = TargetTable.PlanFrequencyUniqueId
		INNER JOIN #PlanFrequencyKey tpfk ON tpfk.Id = pfk.Id

		DELETE TargetTable
		FROM PlanFrequencyCouponCode TargetTable
		INNER JOIN PlanFrequencyKey pfk ON pfk.Id = TargetTable.PlanFrequencyUniqueId
		INNER JOIN #PlanFrequencyKey tpfk ON tpfk.Id = pfk.Id

		DELETE TargetTable
		FROM PlanProductFrequencyCustomField TargetTable
		INNER JOIN PlanFrequencyKey pfk ON pfk.Id = TargetTable.PlanFrequencyUniqueId
		INNER JOIN #PlanFrequencyKey tpfk ON tpfk.Id = pfk.Id

		DELETE TargetTable
		FROM PlanProduct TargetTable
		INNER JOIN PlanRevision pr ON pr.Id = TargetTable.PlanRevisionId
		WHERE pr.PlanId = @id

		DELETE TargetTable 
		From PlanProductKey TargetTable
		INNER JOIN #PlanProductKey tppk ON tppk.Id = TargetTable.Id

		DELETE TargetTable
		FROM PlanFrequencyKey TargetTable
		INNER JOIN #PlanFrequencyKey tpfk ON tpfk.Id = TargetTable.Id

		DELETE TargetTable
		FROM PlanRevision TargetTable
		WHERE TargetTable.PlanId = @Id

		DELETE TargetTable
		FROM PlanFamilyPlan TargetTable
		WHERE TargetTable.PlanId = @Id

		DELETE TargetTable
		FROM [Plan] TargetTable
		Where TargetTable.Id = @Id
	END
	END TRY
	BEGIN CATCH
		EXEC dbo.usp_ErrorHandler
		SET @ERRORFLAG = 1 
	END CATCH

	IF OBJECT_ID('tempdb..#PlanFrequencyKey') IS NOT NULL DROP TABLE #PlanFrequencyKey
	IF OBJECT_ID('tempdb..#PlanProductKey') IS NOT NULL DROP TABLE #PlanProductKey
	

SET NOCOUNT OFF;

GO

