CREATE   PROCEDURE [dbo].[usp_HardDeleteCustomersAndRelatedChildren]
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

CREATE TABLE #Customers ( Id BIGINT PRIMARY KEY)
--leverage batchsize to select top
INSERT INTO #Customers
SELECT TOP(@BatchSize) ParentTable1.Id
FROM Customer ParentTable1   
WHERE ParentTable1.IsDeleted = 1
--we exclude customers with subscriptions and purchases, because there are seperate processes to hard delete those
--on a future runs customers who currently have >=1 subscriptions/purchases will have none, and we can safely delete them

--we also check if we have associated transactions or payment methods
--ignore such customers as any attempt to delete them will throw foriegn key errors
--it is the fault of the application if a purchase is deleted with rows in these tables

AND NOT EXISTS (
		SELECT
		*
	FROM 
		Subscription  targetTable			
		WHERE targetTable.CustomerId = ParentTable1.Id
	)
AND NOT EXISTS (
		SELECT
		*
	FROM 
		Purchase  targetTable			
		WHERE targetTable.CustomerId = ParentTable1.Id OR targetTable.InvoiceOwnerId = ParentTable1.Id
	)
AND NOT EXISTS (
		SELECT
		*
	FROM 
		[Transaction]  targetTable			
		WHERE targetTable.CustomerId = ParentTable1.Id

)
AND NOT EXISTS (
	SELECT
		*
	FROM 
		[PaymentMethod]  targetTable			
		WHERE targetTable.CustomerId = ParentTable1.Id
		AND targetTable.PaymentMethodStatusId <> 2 --deleted

)
AND NOT EXISTS (
	SELECT
		*
	FROM 
		[PaymentMethodSharing]  targetTable			
		WHERE targetTable.CustomerId = ParentTable1.Id

)
AND NOT EXISTS (
		SELECT
		*
	FROM 
		Invoice  targetTable			
		WHERE targetTable.CustomerId = ParentTable1.Id

)
AND NOT EXISTS (
		SELECT
		*
	FROM 
		Customer  targetTable			
		WHERE targetTable.ParentId = ParentTable1.Id

)
AND NOT EXISTS (
		SELECT
		*
	FROM 
		PaymentActivityJournal targetTable			
		WHERE targetTable.CustomerId = ParentTable1.Id
		AND targetTable.PaymentTypeId != 1

)

--check if we have deleted a customer that should not be deleted, and then failed to filter them out in the where clause above
IF EXISTS(
	SELECT
		*
	FROM 
		[Transaction]  targetTable			
		INNER JOIN #Customers c on c.Id = targetTable.CustomerId
)
BEGIN
	RAISERROR (15600,-1,-1, 'transactions exist for some of the customers and we failed to filter them out');
	RETURN 55555
END

IF EXISTS(
	SELECT
		*
	FROM 
		[PaymentMethod]  targetTable
		INNER JOIN #Customers c on c.Id = targetTable.CustomerId
		WHERE targetTable.PaymentMethodStatusId <> 2 --deleted
)
BEGIN
	RAISERROR (15600,-1,-1, 'Non-deleted Payment methods exist for some of the customers and we failed to filter them out');
	RETURN 55555
END

IF EXISTS(
	SELECT
		*
	FROM 
		Purchase  targetTable
		INNER JOIN #Customers c on c.Id = targetTable.CustomerId
		WHERE targetTable.isDeleted = 0
)
BEGIN
	RAISERROR (15600,-1,-1, 'non deleted purchases exist for some of the customers and we failed to filter them out');
	RETURN 55555
END

IF EXISTS(
	SELECT
		*
	FROM 
		Subscription  targetTable
		INNER JOIN #Customers c on c.Id = targetTable.CustomerId
		WHERE targetTable.isDeleted = 0
)
BEGIN
	RAISERROR (15600,-1,-1, 'non deleted subscriptions exist for some of the customers and we failed to filter them out');
	RETURN 55555
END

--try catch with error handling 

SET XACT_ABORT, NOCOUNT ON 
   BEGIN TRY

   
	DECLARE @Deleted_Rows INT;


	--account status journals
	--acquisition
	--address
	--address pref
	--billing period config
	--billing period schedule
	--billing setting
	--billing statment setting
	--credential
	--email control
	--email log attachment
	--email log billing statement
	--email log draft invoice
	--email log
	--email pref
	--integration
	--invoice setting
	--note
	--paj
	--payment validation lock
	--reference
	--sms number
	--starting data
	--status journal
	--ProjectedInvoice
	--QuickBooksLog
	--SelfServicePortalToken
	--twilio notification
	--InstantPaymentNotification
	--Fusebill Support Login
	--CollectionScheduleActivity
    --CollectionNote
    --BillingStatement
    --AccountAutomatedHistoryFailure
    --AvalaraLog
	--txt log
	--txt control
	--txt preference
	--audit trail
	--billing period
	--billing period definition
	--customer




	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerAccountStatusJournal TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerAcquisition TargetTable  
		INNER JOIN #Customers c ON TargetTable.Id = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM [Address] TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerAddressPreferenceId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerAddressPreference TargetTable  
		INNER JOIN #Customers c ON TargetTable.Id = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerBillingPeriodConfiguration TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerBillingSettingId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerBillingSetting TargetTable  
		INNER JOIN #Customers c ON TargetTable.Id = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerBillingStatementSetting TargetTable  
		INNER JOIN #Customers c ON TargetTable.Id = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerCredential TargetTable  
		INNER JOIN #Customers c ON TargetTable.Id = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerEmailControl TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerEmailLogAttachment TargetTable  
		INNER JOIN CustomerEmailLog cel on cel.Id = TargetTable.CustomerEmailLogId
		INNER JOIN #Customers c ON cel.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerEmailEventSummary TargetTable  
		INNER JOIN CustomerEmailLog cel on cel.Id = TargetTable.CustomerEmailLogId
		INNER JOIN #Customers c ON cel.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerEmailLogBillingStatement TargetTable  
		INNER JOIN CustomerEmailLog cel on cel.Id = TargetTable.CustomerEmailLogId
		INNER JOIN #Customers c ON cel.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerEmailLogDraftInvoice TargetTable  
		INNER JOIN CustomerEmailLog cel on cel.Id = TargetTable.CustomerEmailLogId
		INNER JOIN #Customers c ON cel.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SendgridEvents TargetTable
		INNER JOIN CustomerEmailLog cel ON cel.Id = TargetTable.CustomerEmailLogId
		INNER JOIN #Customers c ON cel.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerEmailLog TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerEmailPreference TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerIntegration TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerInvoiceSetting TargetTable  
		INNER JOIN #Customers c ON TargetTable.Id = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerNote TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM PaymentActivityJournal TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id
		WHERE TargetTable.PaymentTypeId = 1 --validate

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerPaymentValidationLock TargetTable  
		INNER JOIN #Customers c ON TargetTable.Id = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM AchCard TargetTable  
		INNER JOIN PaymentMethod pm on pm.Id = TargetTable.Id
		INNER JOIN #Customers c ON pm.CustomerId = c.Id
		WHERE pm.PaymentMethodStatusId = 2 --deleted

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CreditCardExpiryActivity TargetTable  
		INNER JOIN PaymentMethod pm on pm.Id = TargetTable.CreditCardId
		INNER JOIN #Customers c ON pm.CustomerId = c.Id
		WHERE pm.PaymentMethodStatusId = 2 --deleted

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CreditCard TargetTable  
		INNER JOIN PaymentMethod pm on pm.Id = TargetTable.Id
		INNER JOIN #Customers c ON pm.CustomerId = c.Id
		WHERE pm.PaymentMethodStatusId = 2 --deleted

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM PaymentMethod TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id
		WHERE TargetTable.PaymentMethodStatusId = 2 --deleted

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerReference TargetTable  
		INNER JOIN #Customers c ON TargetTable.Id = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerSmSNumber TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerStartingData TargetTable  
		INNER JOIN #Customers c ON TargetTable.Id = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerStatusJournal TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM ProjectedInvoice TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM QuickBooksLog TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM SelfServicePortalToken TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM TwilioNotification TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM InstantPaymentNotification TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM FusebillSupportLogin TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CollectionScheduleActivity TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CollectionNote TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM BillingStatement TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM AccountAutomatedHistoryFailure TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM AvalaraLog TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerTextLog TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerTxtControl TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM CustomerTxtPreference TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM AuditTrail TargetTable  
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id
		WHERE TargetTable.CustomerId IS NOT NULL

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM BillingPeriod TargetTable
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM BillingPeriodPaymentSchedule TargetTable
		INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = TargetTable.BillingPeriodDefinitionId
		INNER JOIN #Customers c ON bpd.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM BillingPeriodDefinition TargetTable
		INNER JOIN #Customers c ON TargetTable.CustomerId = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM PaymentMethodValidationConcurrencyLock TargetTable
		INNER JOIN #Customers c ON TargetTable.Id = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

	SET @Deleted_Rows = 1;
	WHILE (@Deleted_Rows > 0)
	BEGIN
		DELETE TOP(@BatchSize) TargetTable  
		FROM Customer TargetTable  
		INNER JOIN #Customers c ON TargetTable.Id = c.Id

		SET @Deleted_Rows = @@ROWCOUNT;
	END

END TRY
BEGIN CATCH
	EXEC dbo.usp_ErrorHandler
	SET @ERRORFLAG = 1    
END CATCH

IF OBJECT_ID('tempdb..#Customers') IS NOT NULL DROP TABLE #Customers


IF @ERRORFLAG = 1
BEGIN
	RETURN 55555
END

SET NOCOUNT OFF;

GO

