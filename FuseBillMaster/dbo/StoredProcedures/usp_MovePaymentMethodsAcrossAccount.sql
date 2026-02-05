
CREATE PROCEDURE [dbo].[usp_MovePaymentMethodsAcrossAccount]
	@DestinationFusebillID bigint,
	@SourceFusebillID bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Set Destination Customer's Default Payment Method From Source
    UPDATE CustomerBillingSetting
		SET DefaultPaymentMethodId = (SELECT DefaultPaymentMethodId 
										FROM CustomerBillingSetting 
										WHERE Id = @SourceFusebillID)
	WHERE Id = @DestinationFusebillID

	-- Wipe out Source's Default Payment Method
	UPDATE CustomerBillingSetting
		SET DefaultPaymentMethodId = NULL
	WHERE Id = @SourceFusebillID

	-- Swap IDs from Source to Destination
	UPDATE PaymentMethod
		SET CustomerId = @DestinationFusebillID
	WHERE CustomerId = @SourceFusebillID
END

GO

