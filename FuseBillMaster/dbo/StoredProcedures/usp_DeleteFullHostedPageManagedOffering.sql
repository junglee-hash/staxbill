
CREATE   PROCEDURE [dbo].[usp_DeleteFullHostedPageManagedOffering]
	@OfferingId BIGINT
AS
BEGIN

SET XACT_ABORT, NOCOUNT ON 
DECLARE @ERRORFLAG BIT = 0
	BEGIN TRY
	BEGIN TRANSACTION

	DELETE FROM dbo.HostedPageManagedOfferingPreviewPanel
	WHERE Id = @OfferingId

	DELETE FROM dbo.HostedPageManagedCurrencyOfferingRelationship
	WHERE HostedPageManagedOfferingId = @OfferingId

	DELETE FROM dbo.HostedPageManagedOfferingAvailableCountry
	WHERE HostedPageManagedOfferingId = @OfferingId

	DELETE FROM dbo.HostedPageManagedOfferingAvailableSalesTrackingCode
	WHERE HostedPageManagedOfferingId = @OfferingId

	DELETE FROM dbo.HostedPageManagedOfferingCustomerInformation
	WHERE HostedPageManagedOfferingId = @OfferingId

	DELETE FROM dbo.HostedPageManagedOfferingLabel
	WHERE Id = @OfferingId

	DELETE FROM dbo.HostedPageManagedOfferingLoginConfiguration
	WHERE Id = @OfferingId

	DELETE FROM dbo.HostedPageManagedOfferingPaymentMethod
	WHERE HostedPageManagedOfferingId = @OfferingId

	DELETE hpmopf FROM dbo.HostedPageManagedOfferingPlanFrequency hpmopf
	INNER JOIN dbo.HostedPageManagedOfferingPlan hpmop ON hpmop.Id = hpmopf.HostedPageManagedOfferingPlanId
	WHERE HostedPageManagedOfferingId = @OfferingId

	DELETE hpmopp FROM dbo.HostedPageManagedOfferingPlanProduct hpmopp
	INNER JOIN dbo.HostedPageManagedOfferingPlan hpmop ON hpmop.Id = hpmopp.HostedPageManagedOfferingPlanId
	WHERE HostedPageManagedOfferingId = @OfferingId

	DELETE FROM dbo.HostedPageManagedOfferingPlan
	WHERE HostedPageManagedOfferingId = @OfferingId

	DELETE FROM dbo.HostedPageManagedOfferingProduct
	WHERE HostedPageManagedOfferingId = @OfferingId

	DELETE FROM dbo.HostedPageManagedOffering
	WHERE Id = @OfferingId 
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		EXEC dbo.usp_ErrorHandler
		SET @ERRORFLAG = 1 
	END CATCH


END

GO

