
CREATE PROCEDURE [dbo].[usp_UpdateDefaultPaymentMethodId]
	@NewId bigint,
	@OldId bigint
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE CustomerBillingSetting
		SET DefaultPaymentMethodId = @NewId
		WHERE DefaultPaymentMethodId = @OldId
END

GO

