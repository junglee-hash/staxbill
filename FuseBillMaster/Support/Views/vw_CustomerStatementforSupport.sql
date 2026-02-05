

CREATE VIEW [Support].[vw_CustomerStatementforSupport]
AS
SELECT TransactionId, AccountId, CustomerId, TransactionTime, TransactionType, Currency, ProductName, ARLedger AS TransactionAmount, NewBalance AS NewCustomerBalance
FROM     (SELECT    t.Id AS TransactionId, CONVERT(smalldatetime, dbo.fn_GetTimezoneTime(t.EffectiveTimestamp, ap.TimezoneId)) AS TransactionTime, t.CustomerId, c.AccountId, ltt.Name AS TransactionType, lc.IsoName AS Currency, COALESCE (sp.PlanProductName, cre.Reference, ltt.Name) AS ProductName, 
                           clj.ArDebit - clj.ArCredit AS ARLedger, ISNULL
                               ((SELECT   SUM(c.ArDebit) - SUM(c.ArCredit) AS CustomerBalance
                               FROM      dbo.[Transaction] AS t2 with (nolock) INNER JOIN
                                             dbo.vw_CustomerLedgerJournal AS c with (nolock) ON t2.Id = c.TransactionId
                               WHERE    (t2.Id <= t.Id) AND (t2.CustomerId = t.CustomerId) AND (t2.TransactionTypeId NOT IN (6, 9))
                               GROUP BY t2.CustomerId), 0) AS NewBalance, ltt.SortOrder
             FROM      dbo.[Transaction] AS t with (nolock) INNER JOIN
                           dbo.Customer AS c with (nolock) ON t.CustomerId = c.Id INNER JOIN
                           dbo.AccountPreference AS ap with (nolock) ON c.AccountId = ap.Id INNER JOIN
                           Lookup.TransactionType AS ltt  with (nolock) ON t.TransactionTypeId = ltt.Id INNER JOIN
                           Lookup.Currency AS lc with (nolock) ON t.CurrencyId = lc.Id INNER JOIN
                           dbo.vw_CustomerLedgerJournal AS clj with (nolock) ON t.Id = clj.TransactionId LEFT OUTER JOIN
                           dbo.Earning AS e with (nolock) ON t.Id = e.Id LEFT OUTER JOIN
                           dbo.Discount AS d with (nolock) ON t.Id = d.Id LEFT OUTER JOIN
                           dbo.ReverseEarning AS re with (nolock) ON t.Id = re.Id LEFT OUTER JOIN
                           dbo.Tax AS tax with (nolock) ON t.Id = tax.Id LEFT OUTER JOIN
                           dbo.Credit AS cre with (nolock) ON t.Id = cre.Id LEFT OUTER JOIN
                           dbo.ReverseCharge AS rc with (nolock) ON COALESCE (re.ReverseChargeId, t.Id) = rc.Id LEFT OUTER JOIN
                           dbo.Charge AS ch with (nolock) ON COALESCE (e.ChargeId, rc.OriginalChargeId, d.ChargeId, tax.ChargeId, t.Id) = ch.Id LEFT OUTER JOIN
                           dbo.PurchaseCharge AS ppi with (nolock) ON ch.Id = ppi.Id LEFT OUTER JOIN
                           dbo.SubscriptionProductCharge AS spc with (nolock) ON ch.Id = spc.Id LEFT OUTER JOIN
                           dbo.SubscriptionProduct AS sp with (nolock) ON spc.SubscriptionProductId = sp.Id LEFT OUTER JOIN
                           Lookup.ProductResetType AS lprt with (nolock) ON sp.ResetTypeId = lprt.Id LEFT OUTER JOIN
                           dbo.Payment AS pay with (nolock) ON t.Id = pay.Id LEFT OUTER JOIN
                           dbo.PaymentActivityJournal AS paj with (nolock) ON pay.PaymentActivityJournalId = paj.Id LEFT OUTER JOIN
                           dbo.PaymentMethod AS pm with (nolock) ON paj.PaymentMethodId = pm.Id
             WHERE    (t.Amount <> 0) AND (clj.ArCredit <> 0) OR
                           (t.Amount <> 0) AND (clj.ArDebit <> 0)) AS Data

GO

