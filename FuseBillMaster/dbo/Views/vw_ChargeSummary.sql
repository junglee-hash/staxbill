CREATE VIEW [dbo].[vw_ChargeSummary]
AS
SELECT null as Id, c.AccountId, c.Id as CustomerId, CASE WHEN dspc.Id IS NULL THEN prod.Id ELSE sp.ProductId END as ProductId, 
	'Draft' as [Status], dc.EffectiveTimestamp, CASE WHEN dspc.Id IS NULL THEN prod.Code ELSE sp.PlanProductCode END as ProductCode, 
	dc.Name, dc.[Description], dc.Quantity, dc.UnitPrice, dc.ProratedUnitPrice, dc.Amount,
	dc.Amount as RemainingReverseAmount, dc.DraftInvoiceId, null as InvoiceId, null as GLCode,
	dspc.SubscriptionProductId, dpc.PurchaseId, 
	null as RelatedPaymentNotes, null as RelatedCreditNotes, 
	STUFF((SELECT '|||' + Reference FROM (
		SELECT pit.Reference
		FROM DraftCharge dc1 (NOLOCK)
		LEFT JOIN DraftChargeProductItem dcpi (NOLOCK) ON dc.Id = dcpi.DraftChargeId
		LEFT JOIN ProductItem pit (NOLOCK) ON pit.Id = dcpi.ProductItemId and pit.CustomerId = c.Id
		WHERE dc1.Id = dc.Id) Result
	ORDER BY Reference FOR xml path('')), 1, 3, '') as RelatedProductItems
FROM DraftCharge dc (NOLOCK)
INNER JOIN Customer c (NOLOCK) ON c.Id = dc.CustomerId
LEFT JOIN DraftSubscriptionProductCharge dspc (NOLOCK) ON dc.Id = dspc.Id
LEFT JOIN SubscriptionProduct sp (NOLOCK) ON sp.Id = dspc.SubscriptionProductId
LEFT JOIN DraftPurchaseCharge dpc (NOLOCK) ON dc.Id = dpc.Id
LEFT JOIN Purchase p (NOLOCK) ON p.Id = dpc.PurchaseId
LEFT JOIN Product prod (NOLOCK) ON prod.Id = p.ProductId
UNION
SELECT dc.Id, c.AccountId, c.Id as CustomerId, CASE WHEN dspc.Id IS NULL THEN prod.Id ELSE sp.ProductId END as ProductId, 
	'Purchased' as [Status], t.EffectiveTimestamp, CASE WHEN dspc.Id IS NULL THEN prod.Code ELSE sp.PlanProductCode END as ProductCode, 
	dc.Name, t.[Description], dc.Quantity, dc.UnitPrice, dc.ProratedUnitPrice, t.Amount,
	dc.RemainingReverseAmount, null as DraftInvoiceId, dc.InvoiceId, gl.Code as GLCode,
	dspc.SubscriptionProductId, dpc.PurchaseId, 
	STUFF((SELECT '|||' + CONVERT(varchar(100), PaymentId), 
			'^^^' + PaymentMethod + CASE WHEN CardType IS NOT NULL THEN ' (' + CardType + ' ending in ' + CardNumber + ')' ELSE '' END
		FROM (
		SELECT pn.PaymentId, pmt.Name as PaymentMethod, pm.AccountType as CardType, 
		COALESCE(cc.MaskedCardNumber, ach.MaskedAccountNumber) as CardNumber
		FROM Charge dc1 (NOLOCK)
		LEFT JOIN PaymentNote pn (NOLOCK) ON pn.InvoiceId = dc1.InvoiceId
		LEFT JOIN Payment p (NOLOCK) ON p.Id = pn.PaymentId
		LEFT JOIN PaymentActivityJournal paj (NOLOCK) ON paj.Id = p.PaymentActivityJournalId
		LEFT JOIN PaymentMethod pm (NOLOCK) ON pm.Id = paj.PaymentMethodId
		LEFT JOIN CreditCard cc (NOLOCK) ON cc.Id = pm.Id
		LEFT JOIN AchCard ach (NOLOCK) ON ach.Id = pm.Id
		LEFT JOIN Lookup.PaymentMethodType pmt (NOLOCK) ON pmt.Id = paj.PaymentMethodTypeId
		WHERE dc1.Id = dc.Id
		GROUP BY pn.PaymentId, pmt.Name, pm.AccountType, cc.MaskedCardNumber, ach.MaskedAccountNumber) Result
	ORDER BY PaymentId FOR xml path('')), 1, 3, '') as RelatedPaymentNotes,
	STUFF((SELECT '|||' + CONVERT(varchar(100), CreditId) FROM (
		SELECT ca.CreditId
		FROM Charge dc1 (NOLOCK)
		LEFT JOIN CreditAllocation ca (NOLOCK) ON ca.InvoiceId = dc1.InvoiceId
		WHERE dc1.Id = dc.Id) Result
	ORDER BY CreditId FOR xml path('')), 1, 3, '') as RelatedCreditNotes, 
	STUFF((SELECT '|||' + Reference FROM (
		SELECT pit.Reference
		FROM Charge dc1 (NOLOCK)
		LEFT JOIN ChargeProductItem dcpi (NOLOCK) ON dc.Id = dcpi.ChargeId
		LEFT JOIN ProductItem pit (NOLOCK) ON pit.Id = dcpi.ProductItemId and pit.CustomerId = c.Id
		WHERE dc1.Id = dc.Id) Result
	ORDER BY Reference FOR xml path('')), 1, 3, '') as RelatedProductItems
FROM Charge dc (NOLOCK)
INNER JOIN [Transaction] t (NOLOCK) ON dc.Id = t.Id
INNER JOIN Customer c (NOLOCK) ON c.Id = t.CustomerId
LEFT JOIN SubscriptionProductCharge dspc (NOLOCK) ON dc.Id = dspc.Id
LEFT JOIN SubscriptionProduct sp (NOLOCK) ON sp.Id = dspc.SubscriptionProductId
LEFT JOIN PurchaseCharge dpc (NOLOCK) ON dc.Id = dpc.Id
LEFT JOIN Purchase p (NOLOCK) ON p.Id = dpc.PurchaseId
LEFT JOIN Product prod (NOLOCK) ON prod.Id = COALESCE(p.ProductId, sp.ProductId)
LEFT JOIN GLCode gl (NOLOCK) ON gl.Id = COALESCE(dc.GLCodeId, prod.GLCodeId)

GO

