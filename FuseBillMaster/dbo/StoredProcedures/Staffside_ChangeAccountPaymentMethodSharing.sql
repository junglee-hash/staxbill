
CREATE PROCEDURE [dbo].[Staffside_ChangeAccountPaymentMethodSharing]
	@AccountId BIGINT
	,@TurningOff BIT
AS

--Note: we know the joins for setting the new default payment method can return multiple values, we are ok with that inefficiency at this point
IF (@TurningOff = 0)
BEGIN
	--Turning ON account sharing
	--This does not support multi-generation, that is expected to be an extreme edge case
	UPDATE cbs
	SET cbs.DefaultPaymentMethodId = pm.Id
	FROM CustomerBillingSetting cbs
	INNER JOIN Customer c ON c.Id = cbs.Id
	--All payment methods on the parent that are explicitly shared or shared by account default
	INNER JOIN PaymentMethod pm ON pm.CustomerId = c.ParentId AND (pm.Sharing != 0 OR pm.Sharing IS NULL)
	--All payment methods on the parent that have an explicit customer override of don't share for this customer
	LEFT JOIN PaymentMethodSharing pms ON pms.PaymentMethodId = pm.Id AND pms.Sharing = 0 AND pms.CustomerId = c.Id
	WHERE c.AccountId = @AccountId
		AND cbs.DefaultPaymentMethodId IS NULL
		--Only care about customers with parents
		AND c.ParentId IS NOT NULL
		--If we have a customer override it is for do not share
		AND pms.Id IS NULL
		--Only want to set things for active payment methods
		AND pm.PaymentMethodStatusId = 1
END

IF (@TurningOff = 1)
BEGIN
	--Turning OFF account sharing, try to set to their own payment method
	--This partially support multi-generation, but does not go through the full hierarchy to look for another valid payment method as a default
	UPDATE cbs
	--Sets to the one of the customer's payment methods if they have any otherwise it will be NULL
	SET cbs.DefaultPaymentMethodId = pm.Id
	FROM CustomerBillingSetting cbs
	INNER JOIN Customer c ON c.Id = cbs.Id
	--Do not want to wipe payment method if it explicitly shared
	INNER JOIN PaymentMethod dpm ON dpm.Id = cbs.DefaultPaymentMethodId AND (dpm.Sharing != 1 OR dpm.Sharing IS NULL)
	--Default payment method is explicitly shared to this customer
	LEFT JOIN PaymentMethodSharing pms ON pms.PaymentMethodId = cbs.DefaultPaymentMethodId AND pms.CustomerId = c.Id AND pms.Sharing = 1
	--Look for payment methods on this customer
	LEFT JOIN PaymentMethod pm ON pm.CustomerId = c.Id
	WHERE c.AccountId = @AccountId
		AND cbs.DefaultPaymentMethodId IS NOT NULL
		--Only care about customers with parents
		AND c.ParentId IS NOT NULL
		--Only care if they are using a parent's payment method as default
		AND dpm.CustomerId != c.Id
		--Do not want to update customers that have the payment method explicitly shared to them
		AND pms.Id IS NULL
		--Only want to set things for active payment methods
		AND pm.PaymentMethodStatusId = 1
END

GO

