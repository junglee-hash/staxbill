
CREATE PROCEDURE [dbo].[DataFix_SetSubscriptionProductItemSPAJ] 
	@CustomerId BIGINT 
AS
BEGIN

--This technically could have multiple spajs but it will end up setting it with a value
--A value is important, unclear if the specific value matters if there are a bunch of HasCompleted = 0 spajs
UPDATE spi
SET spi.SubscriptionProductActivityJournalId = spaj.Id
FROM SubscriptionProductItem spi
INNER JOIN SubscriptionProduct sp ON sp.Id = spi.SubscriptionProductId
INNER JOIN Subscription s ON s.Id = sp.SubscriptionId
INNER JOIN SubscriptionProductActivityJournal spaj ON spaj.SubscriptionProductId = sp.Id AND spaj.HasCompleted = 0
WHERE s.CustomerId = @CustomerId
AND spi.SubscriptionProductActivityJournalId IS NULL

END

GO

