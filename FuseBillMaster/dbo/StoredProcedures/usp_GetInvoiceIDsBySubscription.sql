
CREATE   PROCEDURE [dbo].[usp_GetInvoiceIDsBySubscription]
	@subscriptionId BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT DISTINCT c.InvoiceId
	FROM Subscription s
	INNER JOIN SubscriptionProduct sp on sp.SubscriptionId = s.Id
	INNER JOIN SubscriptionProductCharge spc on spc.SubscriptionProductId = sp.Id
	INNER JOIN Charge c on c.Id = spc.Id
	WHERE s.Id = @subscriptionId
	AND sp.StatusId <> 2 --deleted


END

GO

