
CREATE PROCEDURE [dbo].[usp_InsertDefaultPaymentMethodForChildren]
	@PaymentMethodId bigint,
	@ParentCustomerId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @PaymentMethodShared BIT 
	SELECT @PaymentMethodShared = Sharing
	FROM PaymentMethod
	WHERE Id = @PaymentMethodId

    UPDATE cbs
		SET cbs.DefaultPaymentMethodId = @PaymentMethodId
	FROM CustomerBillingSetting cbs
	INNER JOIN Customer c ON c.Id = cbs.Id AND c.ParentId = @ParentCustomerId
	INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId
	--Should never really be any customer specific sharing at this point but leaving in to be a bit more careful
	LEFT JOIN PaymentMethodSharing pms ON c.Id = pms.CustomerId 
	WHERE cbs.DefaultPaymentMethodId IS NULL
	AND COALESCE(pms.Sharing, @PaymentMethodShared, afc.PaymentMethodSharing) = 1
END

GO

