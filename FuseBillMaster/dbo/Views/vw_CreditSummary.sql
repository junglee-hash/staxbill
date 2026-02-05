CREATE VIEW [dbo].[vw_CreditSummary]
AS
SELECT t.Id, t.EffectiveTimestamp, CASE WHEN t .TransactionTypeId = 18 THEN t .Amount ELSE 0 END AS DebitAmount, CASE WHEN t .TransactionTypeId = 17 OR
                  t .TransactionTypeId = 16 THEN t .Amount ELSE 0 END AS CreditAmount, t.CustomerId, t.TransactionTypeId, dbo.Customer.AccountId, CASE WHEN d .Id IS NOT NULL THEN d .Reference WHEN c.Id IS NOT NULL 
                  THEN c.Reference WHEN ob.Id IS NOT NULL THEN ob.Reference ELSE NULL END AS Reference,
				  c.SalesTrackingCode1Id, c.SalesTrackingCode2Id, c.SalesTrackingCode3Id, c.SalesTrackingCode4Id, c.SalesTrackingCode5Id
FROM     dbo.[Transaction] AS t INNER JOIN
                  dbo.Customer ON dbo.Customer.Id = t.CustomerId LEFT OUTER JOIN
                  dbo.Credit AS c ON t.Id = c.Id LEFT OUTER JOIN
                  dbo.Debit AS d ON t.Id = d.Id LEFT OUTER JOIN
                  dbo.OpeningBalance AS ob ON t.Id = ob.Id
WHERE  (t.TransactionTypeId IN (16, 17, 18))

GO

