CREATE   VIEW [Reporting].[vw_CustomerARActivity]
AS

WITH CurrentOutstandingBalance AS 
(
	SELECT 
		I.Id AS InvoiceId
		,SUM(ps.OutstandingBalance) AS OutstandingBalance
		,SUM(ps.Amount) as InvoiceTotal
	FROM dbo.Invoice AS I 
	INNER JOIN dbo.PaymentSchedule AS ps ON I.Id = ps.InvoiceId 
    GROUP BY I.Id
)
SELECT CONCAT(CAST(t.Id AS varchar(100)), '-', ABS(CAST(NEWID() AS binary(6)) % 1000) + 1) AS Id, 
	t.Id AS TransactionId, 
	t.CustomerId, 
	c.Reference as CustomerReference,
	t.AccountId, 
	t.EffectiveTimestamp, 
	tt.Name AS TransactionType, 
    isnull(
    CASE 
        WHEN t.TransactionTypeId IN (3, 4, 5) THEN 
            CASE 
                WHEN afc.ShowFirstSix = 1 AND cc.Id IS NOT NULL AND cc.FirstSix IS NOT NULL THEN 
                    pmt.Name + ' (' + pm.AccountType + '|' + cc.FirstSix + '...' + cc.MaskedCardNumber + ')'
                    + CASE 
                        WHEN pm.PaymentMethodNickname IS NOT NULL 
                            THEN ' - ' + pm.PaymentMethodNickname 
                        ELSE '' 
                      END
                ELSE 
                    COALESCE(
                        pmt.Name 
                        + ' (' 
                        + pm.AccountType 
                        + ISNULL(' ending in ' + ISNULL(cc.MaskedCardNumber, acc.MaskedAccountNumber), '') 
                        + ')'
                        + CASE 
                            WHEN pm.PaymentMethodNickname IS NOT NULL 
                                THEN ' - ' + pm.PaymentMethodNickname 
                            ELSE '' 
                          END
                        , pmt.Name
                    )
            END
        ELSE COALESCE(taxr.Name, ch.Name) 
    END,
    tt.Name
) AS Name,
	COALESCE (CAST(taxr.Percentage AS varchar(10)), t.Description, cred.Reference, ob.Reference) AS Description, 
    COALESCE (sp.PlanProductCode, prod.Code) AS ProductCode, 
	paj.Id AS PaymentActivityId, 
	COALESCE (taxr.RegistrationCode, wo.Reference, rc.Reference, ref.Reference, paj.AuthorizationCode) AS Reference, 
	COALESCE (pay.Reference, cred.Reference, ref.Reference, rc.Reference, wo.Reference) AS ManualReference, 
	I.Id AS InvoiceId, 
	I.InvoiceNumber, 
	I.PoNumber,
	I.Notes as InvoiceNote,
	cob.OutstandingBalance, 
	cob.InvoiceTotal,
    CAST(CASE WHEN i.Id IS NOT NULL THEN COALESCE (pn.Amount, refn.Amount, oba.Amount, ca.Amount, da.Amount, t.Amount) ELSE 0 END AS decimal(18, 2)) AS AllocationAmount, 
    CASE WHEN t.TransactionTypeId IN (1, 20) THEN ch.Quantity WHEN d.DiscountTypeId = 3 THEN d.Quantity ELSE 1 END AS Quantity, 
	CASE WHEN t.TransactionTypeId IN (4, 5, 7, 8, 9, 12, 15, 18) THEN t .Amount * - 1 
		WHEN ch.Id = t .Id THEN ch.UnitPrice 
		WHEN d.DiscountTypeId = 3 THEN d.ConfiguredDiscountAmount  
		ELSE t .Amount END AS UnitPrice, 
	CASE WHEN tt.ARBalanceMultiplier >= 0 THEN t.Amount ELSE 0 END as ArDebit, 
	CASE WHEN tt.ARBalanceMultiplier <= 0 THEN t.Amount ELSE 0 END as ArCredit, 
	gl.Code as GLCode,
	COALESCE (vrt.OriginalReverseTaxId, vrd.OriginalReverseDiscountId, vrc.OriginalReverseChargeId, db.OriginalCreditId, ref.OriginalPaymentId, rd.ReverseChargeId, d.ChargeId, rtax.ReverseChargeId, tax.ChargeId, rc.OriginalChargeId, ch.Id, pay.Id, wo.Id,t.Id) AS AssociatedId, 
	ch.Id as ChargeId,
	tt.SortOrder AS AssociatedOrder,
	sp.SubscriptionId AS SubscriptionId

FROM dbo.[Transaction] AS t 
INNER JOIN dbo.Customer AS c ON t.CustomerId = c.Id
INNER JOIN Lookup.TransactionType AS tt ON t.TransactionTypeId = tt.Id 
LEFT OUTER JOIN dbo.Debit AS db ON t.TransactionTypeId = 18 AND t.Id = db.Id 
LEFT OUTER JOIN dbo.DebitAllocation AS da ON t.TransactionTypeId = 18 AND db.Id = da.DebitId 
LEFT OUTER JOIN dbo.Credit AS cred ON t.TransactionTypeId IN (17,18) AND COALESCE (db.OriginalCreditId, t.Id) = cred.Id 
LEFT OUTER JOIN dbo.CreditAllocation AS ca ON t.TransactionTypeId IN (17,18) AND cred.Id = ca.CreditId AND t.Id = cred.Id 
LEFT OUTER JOIN dbo.Refund AS ref ON t.TransactionTypeId IN (4,5,25) AND t.Id = ref.Id 
LEFT OUTER JOIN dbo.RefundNote AS refn ON t.TransactionTypeId IN (4,5) AND t.Id = refn.RefundId 
LEFT OUTER JOIN dbo.Payment AS pay ON t.TransactionTypeId = 3 AND t.Id = pay.Id 
LEFT OUTER JOIN dbo.PaymentNote AS pn ON t.TransactionTypeId = 3 AND t.Id = pn.PaymentId 
LEFT OUTER JOIN dbo.PaymentActivityJournal AS paj ON t.TransactionTypeId IN (3,4,5,25) AND COALESCE (pay.PaymentActivityJournalId, ref.PaymentActivityJournalId) = paj.Id 
LEFT OUTER JOIN Lookup.PaymentMethodType AS pmt ON paj.PaymentMethodTypeId = pmt.Id 
LEFT OUTER JOIN dbo.PaymentMethod AS pm ON paj.PaymentMethodId = pm.Id 
LEFT OUTER JOIN dbo.CreditCard AS cc ON pm.Id = cc.Id 
LEFT OUTER JOIN dbo.AchCard AS acc ON pm.Id = acc.Id 
LEFT OUTER JOIN dbo.ReverseDiscount AS rd ON t.TransactionTypeId IN (15,22) AND t.Id = rd.Id 
LEFT OUTER JOIN dbo.Discount AS d ON COALESCE (rd.OriginalDiscountId, t.Id) = d.Id 
LEFT OUTER JOIN dbo.ReverseTax AS rtax ON t.TransactionTypeId = 12 AND t.Id = rtax.Id 
LEFT OUTER JOIN dbo.Tax AS tax ON t.TransactionTypeId IN (11,12) AND COALESCE (rtax.OriginalTaxId, t.Id) = tax.Id 
LEFT OUTER JOIN dbo.TaxRule AS taxr ON t.TransactionTypeId IN (11,12) AND tax.TaxRuleId = taxr.Id 
LEFT OUTER JOIN dbo.ReverseCharge AS rc ON t.TransactionTypeId IN (7,24) AND t.Id = rc.Id 
left outer join dbo.VoidReverseCharge as vrc on t.TransactionTypeId in (28,29) and t.Id = vrc.Id
left outer join dbo.VoidReverseDiscount as vrd on t.TransactionTypeId in (31, 32) and t.Id = vrd.Id
left outer join dbo.VoidReverseTax as vrt on t.TransactionTypeId = 30 and t.Id = vrt.Id
LEFT OUTER JOIN dbo.Charge AS ch ON COALESCE (tax.ChargeId, d.ChargeId, rc.OriginalChargeId, t.Id) = ch.Id 
LEFT OUTER JOIN dbo.SubscriptionProductCharge AS spc ON spc.Id = ch.Id 
LEFT OUTER JOIN dbo.SubscriptionProduct AS sp ON spc.SubscriptionProductId = sp.Id 
LEFT OUTER JOIN dbo.PurchaseCharge AS pc ON pc.Id = ch.Id 
LEFT OUTER JOIN dbo.Purchase as p ON p.Id = pc.PurchaseId 
LEFT OUTER JOIN dbo.Product AS prod ON prod.Id = COALESCE(p.ProductId, sp.ProductId)
LEFT OUTER JOIN dbo.GLCode AS gl ON gl.Id = COALESCE(ch.GLCodeId, prod.GLCodeId) 
LEFT OUTER JOIN dbo.WriteOff AS wo ON t.TransactionTypeId = 10 AND t.Id = wo.Id 
LEFT OUTER JOIN dbo.OpeningBalance AS ob ON t.TransactionTypeId = 16 AND t.Id = ob.Id 
LEFT OUTER JOIN dbo.OpeningBalanceAllocation AS oba ON t.TransactionTypeId = 16 AND ob.Id = oba.OpeningBalanceId 
LEFT OUTER JOIN dbo.Invoice AS I ON COALESCE (ch.InvoiceId, pn.InvoiceId, ca.InvoiceId, da.InvoiceId, oba.InvoiceId, refn.InvoiceId, wo.InvoiceId) = I.Id
LEFT OUTER JOIN CurrentOutstandingBalance AS cob ON I.Id = cob.InvoiceId 
INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId
--Transactions that have AR Balance Modifier that is not 0
WHERE  t.TransactionTypeId NOT IN (6,9,13,23,26,27)

GO

