
CREATE PROCEDURE [dbo].[usp_CouponIsUsed]
	@CouponId bigint
	, @CustomerId bigint
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CouponIsUsed BIT = 0;

	IF EXISTS (
		SELECT scc.Id
		FROM SubscriptionCouponCode scc
		INNER JOIN CouponCode cc ON cc.Id = scc.CouponCodeId
			AND cc.CouponId = @CouponId
		INNER JOIN Subscription s ON s.Id = scc.SubscriptionId
			AND s.CustomerId = @CustomerId
		)
			SET @CouponIsUsed = 1

	IF @CouponIsUsed = 0
	BEGIN
		
		IF EXISTS (
			SELECT pcc.Id
			FROM PurchaseCouponCode pcc
			INNER JOIN CouponCode cc ON cc.Id = pcc.CouponCodeId
				AND cc.CouponId = @CouponId
			INNER JOIN Purchase p ON p.Id = pcc.PurchaseId
				AND p.CustomerId = @CustomerId
		)
			SET @CouponIsUsed = 1
	END

	SELECT @CouponIsUsed

END

GO

