CREATE PROCEDURE [dbo].[usp_HardDeleteSubscriptionsAndRelatedChildren]
--DECLARE 
@BatchSize INT = NULL

AS

SET NOCOUNT ON;

IF @BatchSize IS NULL
BEGIN
	SET @BatchSize = 1000
END

DECLARE @ERRORFLAG BIT = 0

/** Id Table **/

CREATE TABLE #Subscriptions ( Id BIGINT PRIMARY KEY)
--leverage batchsize to select top
INSERT INTO #Subscriptions
SELECT TOP(@BatchSize) ParentTable1.Id
FROM Subscription ParentTable1   
WHERE ParentTable1.IsDeleted = 1
	--AB#46161 explicit statuses to prevent erroring in unexpected cases
	AND ParentTable1.StatusId IN (1,8) --Draft/StandingOrder
	--AB#32092 excluding instead of erroring as there are more than expected
	AND NOT EXISTS (
		SELECT
		*
	FROM 
		DraftSubscriptionProductCharge  targetTable			
		INNER JOIN SubscriptionProduct sp ON TargetTable.SubscriptionProductId = sp.Id
		WHERE sp.SubscriptionId = ParentTable1.Id
	)
	AND NOT EXISTS (
		SELECT
		*
	FROM 
		SubscriptionProductActivityJournalDraftCharge  targetTable
		INNER JOIN SubscriptionProductActivityJournal spaj ON TargetTable.SubscriptionProductActivityJournalId = spaj.Id			
		INNER JOIN SubscriptionProduct sp ON spaj.SubscriptionProductId = sp.Id
		WHERE sp.SubscriptionId = ParentTable1.Id
	)

--check if charges still exist, error if they do
IF EXISTS(
	SELECT
		*
	FROM 
		DraftSubscriptionProductCharge  targetTable			
		INNER JOIN SubscriptionProduct sp ON TargetTable.SubscriptionProductId = sp.Id
		INNER JOIN #Subscriptions s ON sp.SubscriptionId = s.Id
)
BEGIN
	RAISERROR (15600,-1,-1, 'Draft charges exist for some of the subscriptions');
	RETURN 55555
END

IF EXISTS(
	SELECT
		*
	FROM 
		SubscriptionProductActivityJournalDraftCharge  targetTable
		INNER JOIN SubscriptionProductActivityJournal spaj ON TargetTable.SubscriptionProductActivityJournalId = spaj.Id			
		INNER JOIN SubscriptionProduct sp ON spaj.SubscriptionProductId = sp.Id
		INNER JOIN #Subscriptions s ON sp.SubscriptionId = s.Id
)
BEGIN
	RAISERROR (15600,-1,-1, 'Subscription Product Activity Journal Draft Charges exist for some of the subscriptions');
	RETURN 55555
END

--try catch with error handling 

SET XACT_ABORT, NOCOUNT ON 
   BEGIN TRY

   --create pool of existing billing period definitions to later filter by on empty delete
   CREATE TABLE #BillingPeriodDefinitionPool ( Id BIGINT PRIMARY KEY)
		INSERT INTO #BillingPeriodDefinitionPool
		SELECT DISTINCT(ParentTable1.Id)
		FROM BillingPeriodDefinition ParentTable1   
		INNER JOIN Subscription s on s.BillingPeriodDefinitionId = ParentTable1.Id
		INNER JOIN #Subscriptions sub on sub.Id = s.Id
   
	DECLARE @Deleted_Rows INT;

	--sub coupons
	--sub custom field
	--sub prod price override
	--sub prod override
	--sub prod activity jour
	--sub prod items
	--sub prod discount
	--sub prod custom field
	--sub prod price range
	--sub prod price uplift
	--sub prod starting data
	--sub prod journals
	--sub prod
	--sub status journals
	--sub override
	--sub	
	--delete empty billing period def


	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionCouponCode TargetTable  
		INNER JOIN #Subscriptions s ON TargetTable.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionCustomField TargetTable  
		INNER JOIN #Subscriptions s ON TargetTable.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM PriceRangeOverride TargetTable  
		INNER JOIN SubscriptionProduct sp ON TargetTable.PricingModelOverrideId = sp.Id
		INNER JOIN #Subscriptions s ON sp.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM PricingModelOverride TargetTable  
		INNER JOIN SubscriptionProduct sp ON TargetTable.Id = sp.Id
		INNER JOIN #Subscriptions s ON sp.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionProductOverride TargetTable  
		INNER JOIN SubscriptionProduct sp ON TargetTable.Id = sp.Id
		INNER JOIN #Subscriptions s ON sp.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	
CREATE TABLE #SubscriptionProductItems ( Id BIGINT PRIMARY KEY)
INSERT INTO #SubscriptionProductItems
SELECT ParentTable1.Id
FROM SubscriptionProductItem ParentTable1  
INNER JOIN  SubscriptionProduct sp ON ParentTable1.SubscriptionProductId = sp.Id
INNER JOIN #Subscriptions s ON sp.SubscriptionId = s.Id


	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionProductItem TargetTable  
		INNER JOIN #SubscriptionProductItems spi ON TargetTable.Id = spi.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM ProductItem TargetTable  
		INNER JOIN #SubscriptionProductItems spi ON TargetTable.Id = spi.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionProductActivityJournal TargetTable  
		INNER JOIN SubscriptionProduct sp ON TargetTable.SubscriptionProductId = sp.Id
		INNER JOIN #Subscriptions s ON sp.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionProductDiscount TargetTable  
		INNER JOIN SubscriptionProduct sp ON TargetTable.SubscriptionProductId = sp.Id
		INNER JOIN #Subscriptions s ON sp.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionProductCustomField TargetTable  
		INNER JOIN SubscriptionProduct sp ON TargetTable.SubscriptionProductId = sp.Id
		INNER JOIN #Subscriptions s ON sp.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionProductPriceRange TargetTable  
		INNER JOIN SubscriptionProduct sp ON TargetTable.SubscriptionProductId = sp.Id
		INNER JOIN #Subscriptions s ON sp.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionProductPriceUplift TargetTable  
		INNER JOIN SubscriptionProduct sp ON TargetTable.SubscriptionProductId = sp.Id
		INNER JOIN #Subscriptions s ON sp.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionProductStartingData TargetTable  
		INNER JOIN SubscriptionProduct sp ON TargetTable.Id = sp.Id
		INNER JOIN #Subscriptions s ON sp.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionProductJournal TargetTable  
		INNER JOIN SubscriptionProduct sp ON TargetTable.SubscriptionProductId = sp.Id
		INNER JOIN #Subscriptions s ON sp.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionProduct TargetTable  
		INNER JOIN #Subscriptions s ON TargetTable.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionStatusJournal TargetTable  
		INNER JOIN #Subscriptions s ON TargetTable.SubscriptionId = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SubscriptionOverride TargetTable  
		INNER JOIN #Subscriptions s ON TargetTable.Id = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM Subscription TargetTable  
		INNER JOIN #Subscriptions s ON TargetTable.Id = s.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	--select empty bpds

	CREATE TABLE #BillingPeriodDefinitions ( Id BIGINT PRIMARY KEY)

	INSERT INTO #BillingPeriodDefinitions
	SELECT bpd.Id 
	FROM BillingPeriodDefinition bpd 
	LEFT JOIN Subscription sub on bpd.Id = sub.BillingPeriodDefinitionId
	INNER JOIN #BillingPeriodDefinitionPool bpdPool on bpdPool.Id = bpd.Id
	WHERE sub.Id IS NULL

	--delete empty bpd

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM BillingPeriod TargetTable  
		INNER JOIN #BillingPeriodDefinitions bpd ON TargetTable.BillingPeriodDefinitionId = bpd.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM BillingPeriodPaymentSchedule TargetTable  
		INNER JOIN #BillingPeriodDefinitions bpd ON TargetTable.BillingPeriodDefinitionId = bpd.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM BillingPeriodDefinition TargetTable  
		INNER JOIN #BillingPeriodDefinitions bpd ON TargetTable.Id = bpd.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

END TRY
BEGIN CATCH
	EXEC dbo.usp_ErrorHandler
	SET @ERRORFLAG = 1    
END CATCH

IF OBJECT_ID('tempdb..#Subscriptions') IS NOT NULL DROP TABLE #Subscriptions
IF OBJECT_ID('tempdb..#BillingPeriodDefinitions') IS NOT NULL DROP TABLE #BillingPeriodDefinitions  
IF OBJECT_ID('tempdb..#BillingPeriodDefinitionPool') IS NOT NULL DROP TABLE #BillingPeriodDefinitionPool
IF OBJECT_ID('tempdb..#SubscriptionProductItems') IS NOT NULL DROP TABLE #SubscriptionProductItems


IF @ERRORFLAG = 1
BEGIN
	RETURN 55555
END

SET NOCOUNT OFF;

GO

