
CREATE PROCEDURE [dbo].[usp_DeleteProjectedInvoicesSystemWide]
	@EffectiveDate DATETIME
AS

SET NOCOUNT ON

BEGIN TRANSACTION

DECLARE @BatchSize INT = 1000

DECLARE @DraftInvoices TABLE (DraftInvoiceId BIGINT)
DECLARE @DraftCharges TABLE (DraftChargeId BIGINT)

INSERT INTO @DraftInvoices
SELECT TOP(@BatchSize) Id
FROM DraftInvoice
WHERE DraftInvoiceStatusId = 5
	AND EffectiveTimestamp < DATEADD(HOUR, -6, @EffectiveDate)

INSERT INTO @DraftCharges
SELECT Id
FROM DraftCharge dc
INNER JOIN @DraftInvoices di ON dc.DraftInvoiceId = di.DraftInvoiceId


-- START DELETIONS

DELETE child 
FROM SubscriptionProductActivityJournalDraftCharge child
INNER JOIN @DraftCharges dc ON dc.DraftChargeId = child.DraftChargeId

DELETE child 
FROM DraftDiscount child
INNER JOIN @DraftCharges dc ON dc.DraftChargeId = child.DraftChargeId

DELETE child 
FROM DraftChargeProductItem child
INNER JOIN @DraftCharges dc ON dc.DraftChargeId = child.DraftChargeId

DELETE child 
FROM DraftTax child
INNER JOIN @DraftCharges dc ON dc.DraftChargeId = child.DraftChargeId

DELETE child
FROM DraftSubscriptionProductCharge child
INNER JOIN @DraftCharges dc ON dc.DraftChargeId = child.Id

DELETE child
FROM DraftPurchaseCharge child
INNER JOIN @DraftCharges dc ON dc.DraftChargeId = child.Id

DELETE child
FROM DraftChargeTier child
INNER JOIN @DraftCharges dc ON dc.DraftChargeId = child.DraftChargeId

DELETE child
FROM DraftCharge child
INNER JOIN @DraftCharges dc ON dc.DraftChargeId = child.Id

DELETE child
FROM DraftPaymentSchedule child
INNER JOIN @DraftInvoices di ON di.DraftInvoiceId = child.DraftInvoiceId

DELETE child
FROM ProjectedInvoice child
WHERE EffectiveTimestamp < DATEADD(HOUR, -6, @EffectiveDate)

DELETE child
FROM CustomerEmailLogDraftInvoice child
INNER JOIN @DraftInvoices di ON di.DraftInvoiceId = child.DraftInvoiceId

DELETE parent
FROM DraftInvoice parent
INNER JOIN @DraftInvoices di ON di.DraftInvoiceId = parent.Id

COMMIT TRANSACTION

SET NOCOUNT OFF

SELECT COUNT(*)
FROM @DraftInvoices

GO

