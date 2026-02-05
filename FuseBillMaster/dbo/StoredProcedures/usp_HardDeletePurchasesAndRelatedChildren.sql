

CREATE   PROCEDURE [dbo].[usp_HardDeletePurchasesAndRelatedChildren]
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

CREATE TABLE #Purchases ( Id BIGINT PRIMARY KEY)
--leverage batchsize to select top
INSERT INTO #Purchases
SELECT TOP(@BatchSize) ParentTable1.Id
FROM Purchase ParentTable1   
WHERE ParentTable1.IsDeleted = 1

--check if we have deleted a purchase that should not be deleted
--ignore such purchases as any attempt to delete them will throw foriegn key errors
--it is the fault of the application if a purchase is deleted with rows in these tables
AND NOT EXISTS(
	SELECT
		*
	FROM 
		PurchaseCharge  targetTable			
		Where ParentTable1.Id = targetTable.PurchaseId
)
AND NOT EXISTS(
	SELECT
		*
	FROM 
		DraftPurchaseCharge  targetTable			
		Where ParentTable1.Id = targetTable.PurchaseId
)

--check if we have deleted a purchase that should not be deleted, and then failed to filter them out in the where clause above
IF EXISTS(
	SELECT
		*
	FROM 
		PurchaseCharge  targetTable			
		INNER JOIN #Purchases p on p.Id = targetTable.PurchaseId
)
BEGIN
	RAISERROR (15600,-1,-1, 'purchase charges exist for some of the purchases and we failed to filter them out');
	RETURN 55555
END

IF EXISTS(
	SELECT
		*
	FROM 
		DraftPurchaseCharge  targetTable			
		INNER JOIN #Purchases p on p.Id = targetTable.PurchaseId
)
BEGIN
	RAISERROR (15600,-1,-1, 'draft purchase charges exist for some of the purchases and we failed to filter them out');
	RETURN 55555
END


--try catch with error handling 

SET XACT_ABORT, NOCOUNT ON 
   BEGIN TRY
   
	DECLARE @Deleted_Rows INT;

	--coupon code
	--custom field
	--discount
	--earning discount schedule
	--earning schedule
	--purchase price range
	--opportunity purchase
	--purchase product item
	--product item	
	--purchase table

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM PurchaseCouponCode TargetTable  
		INNER JOIN #Purchases p ON TargetTable.PurchaseId = p.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM PurchaseCustomField TargetTable  
		INNER JOIN #Purchases p ON TargetTable.PurchaseId = p.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM PurchaseDiscount TargetTable  
		INNER JOIN #Purchases p ON TargetTable.PurchaseId = p.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM PurchaseEarningDiscountSchedule TargetTable  
		INNER JOIN PurchaseEarningSchedule pes on pes.Id = TargetTable.PurchaseEarningScheduleId
		INNER JOIN #Purchases p ON pes.PurchaseId = p.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM PurchaseEarningSchedule TargetTable  
		INNER JOIN #Purchases p ON TargetTable.PurchaseId = p.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM PurchasePriceRange TargetTable  
		INNER JOIN #Purchases p ON TargetTable.PurchaseId = p.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SalesforceOpportunityPurchase TargetTable
		INNER JOIN #Purchases p ON p.Id = TargetTable.PurchaseId

		SET @Deleted_Rows = @@ROWCOUNT;
	END

CREATE TABLE #PurchaseProductItems ( Id BIGINT PRIMARY KEY)
INSERT INTO #PurchaseProductItems
SELECT ParentTable1.Id
FROM PurchaseProductItem ParentTable1
INNER JOIN #Purchases p ON ParentTable1.PurchaseId = p.Id


	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM PurchaseProductItem TargetTable  
		INNER JOIN #Purchases p ON TargetTable.PurchaseId = p.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM ProductItem TargetTable
		INNER JOIN #PurchaseProductItems ppi ON ppi.Id = TargetTable.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END


	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM Purchase TargetTable  
		INNER JOIN #Purchases p ON TargetTable.Id = p.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END


END TRY
BEGIN CATCH
	EXEC dbo.usp_ErrorHandler
	SET @ERRORFLAG = 1    
END CATCH

IF OBJECT_ID('tempdb..#Purchases') IS NOT NULL DROP TABLE #Purchases
IF OBJECT_ID('tempdb..#PurchaseProductItems') IS NOT NULL DROP TABLE #PurchaseProductItems


IF @ERRORFLAG = 1
BEGIN
	RETURN 55555
END

SET NOCOUNT OFF;

GO

