
CREATE PROCEDURE [dbo].[usp_ValidateDraftInvoiceDelete] (
	@DraftInvoiceId bigint
	, @CustomerId bigint
	, @AccountId bigint
) AS

SET NOCOUNT, XACT_ABORT ON;

-- Expect NO results when all subscriptions and purchases on this draft invoice are flagged with IsDeleted
-- If any results that means a draft charge on this invoice is not tied to a deleted subscription or purchase
;WITH NotFullyDeleted AS
(
	SELECT di.Id
	FROM DraftInvoice di
	INNER JOIN DraftCharge dc ON di.Id = dc.DraftInvoiceId
	INNER JOIN DraftSubscriptionProductCharge dps ON dps.Id = dc.Id
	INNER JOIN SubscriptionProduct sp ON sp.Id = dps.SubscriptionProductId
	INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
	INNER JOIN Customer c ON c.Id = di.CustomerId
		AND c.AccountId = @AccountId
	WHERE s.IsDeleted = 0
		AND di.Id = @DraftInvoiceId
		AND di.CustomerId = @CustomerId

UNION ALL

	SELECT di.Id
	FROM DraftInvoice di
	INNER JOIN DraftCharge dc ON di.Id = dc.DraftInvoiceId
	INNER JOIN DraftPurchaseCharge dps ON dps.Id = dc.Id
	INNER JOIN Purchase pu ON pu.Id = dps.PurchaseId
	INNER JOIN Customer c ON c.Id = di.CustomerId
		AND c.AccountId = @AccountId
	WHERE pu.IsDeleted = 0
		AND di.Id = @DraftInvoiceId
		AND di.CustomerId = @CustomerId

)
SELECT COUNT(*)
FROM NotFullyDeleted

SET NOCOUNT, XACT_ABORT OFF;

GO

