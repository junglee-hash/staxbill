CREATE   PROCEDURE [dbo].[usp_MarkSpajsAsComplete]
	@billingPeriodDefinitionIds AS dbo.IDList READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    UPDATE spaj
		SET HasCompleted = 1
	FROM SubscriptionProductActivityJournal spaj
	INNER JOIN SubscriptionProduct sp ON sp.Id = spaj.SubscriptionProductId
	INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
	INNER JOIN @billingPeriodDefinitionIds bpd ON bpd.Id = s.BillingPeriodDefinitionId
	WHERE sp.Included = 0
	AND spaj.HasCompleted = 0
END

GO

