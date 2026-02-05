
CREATE PROCEDURE [dbo].[usp_DeleteProjectedInvoicesForBillingPeriodDefinition]
	@BillingPeriodDefinitionId bigint
AS

SET NOCOUNT ON;

BEGIN TRANSACTION

DECLARE @DraftInvoices TABLE (DraftInvoiceId BIGINT)
DECLARE @DraftCharges TABLE (DraftChargeId BIGINT)

INSERT INTO @DraftInvoices
SELECT distinct df.Id
FROM DraftInvoice df
join BillingPeriod bp on bp.Id = df.BillingPeriodId
where
	df.DraftInvoiceStatusId = 5
	and bp.BillingPeriodDefinitionId = @BillingPeriodDefinitionId

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
join DraftInvoice df on df.Id = child.ProjectedInvoiceId
join BillingPeriod bp on bp.Id = df.BillingPeriodId
where
	df.DraftInvoiceStatusId = 5
	and bp.BillingPeriodDefinitionId = @BillingPeriodDefinitionId

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

