
CREATE VIEW [dbo].[vw_PaymentSummary]
AS
SELECT pj.Id, 
	t.Id AS TransactionId, 
	pj.EffectiveTimestamp, 
	CASE WHEN pj.PaymentTypeId <> 3 THEN pj.Amount ELSE 0 END AS DebitAmount, 
	CASE WHEN pj.PaymentTypeId = 3 THEN pj.Amount ELSE 0 END AS CreditAmount, 
    pj.CustomerId, 
	pt.Name AS PaymentType, 
	t.TransactionTypeId, 
	ps.Name AS PaymentSource, 
	c.AccountId, 
	CASE WHEN r.Id IS NOT NULL THEN r.Reference WHEN p.Id IS NOT NULL THEN p.Reference ELSE NULL END AS Reference, 
	COALESCE(p.ReferenceDate, r.ReferenceDate) AS ReferenceDate,
	r.OriginalPaymentId, 
	pa.Name AS PaymentStatus, 
	pmt.Name AS PaymentMethod, 
	pm.AccountType, 
	COALESCE (cc.MaskedCardNumber, ac.MaskedAccountNumber) AS CardNumber, 
	pj.ParentCustomerId,
	pj.SettlementStatusId, 
	(CASE WHEN (pm.Id IS NULL AND pmt.Id = 3) Then 1 Else 0 END) AS OneTimePayment,
	pj.IsDebit,
	pm.PaymentMethodNickname
FROM     dbo.PaymentActivityJournal AS pj INNER JOIN
                  Lookup.PaymentActivityStatus AS pa ON pa.Id = pj.PaymentActivityStatusId INNER JOIN
                  Lookup.PaymentType AS pt ON pt.Id = pj.PaymentTypeId INNER JOIN
                  Lookup.PaymentSource AS ps ON ps.Id = pj.PaymentSourceId INNER JOIN
                  dbo.Customer AS c ON c.Id = pj.CustomerId LEFT OUTER JOIN
                  Lookup.PaymentMethodType AS pmt ON pmt.Id = pj.PaymentMethodTypeId LEFT OUTER JOIN
                  dbo.Payment AS p ON pj.Id = p.PaymentActivityJournalId LEFT OUTER JOIN
                  dbo.Refund AS r ON pj.Id = r.PaymentActivityJournalId LEFT OUTER JOIN
                  dbo.[Transaction] AS t ON t.Id = p.Id OR t.Id = r.Id LEFT OUTER JOIN
                  dbo.PaymentMethod AS pm ON pj.PaymentMethodId = pm.Id LEFT OUTER JOIN
                  dbo.CreditCard AS cc ON cc.Id = pm.Id LEFT OUTER JOIN
                  dbo.AchCard AS ac ON ac.Id = pm.Id

GO

