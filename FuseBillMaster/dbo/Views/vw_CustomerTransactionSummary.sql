
CREATE VIEW [dbo].[vw_CustomerTransactionSummary]
AS

    SELECT CONCAT(CAST(t.Id AS varchar(100)), '-', ABS(CAST(NEWID() AS binary(6)) % 1000) + 1) AS Id, 
			t.Id AS TransactionId, 
			t.CustomerId, 
			c.AccountId, 
			t.EffectiveTimestamp, 
			dbo.GetTransactionName(t.TransactionTypeId, tt.Name) AS TransactionType, 
            isnull(CASE WHEN t .TransactionTypeId IN (3, 4, 5) THEN COALESCE (pmt.Name + ' (' + pm.AccountType + + ISNULL(' ending in ' + ISNULL(cc.MaskedCardNumber, acc.MaskedAccountNumber), '') + ')', pmt.Name) 
                      ELSE COALESCE (taxr.Name, ch.Name) END,tt.Name) AS Name, COALESCE (CAST(taxr.Percentage AS varchar(10)), t.Description, cred.Reference, ob.Reference, pay.Reference, ref.Reference) AS Description, 
            COALESCE (taxr.RegistrationCode, wo.Reference, rc.Reference, ref.Reference, paj.AuthorizationCode) AS Reference,
            CASE WHEN t.TransactionTypeId IN (1, 20) THEN ch.Quantity WHEN d.DiscountTypeId = 3 THEN d.Quantity ELSE 1 END AS Quantity, 
			CASE WHEN t.TransactionTypeId IN (4, 5, 7, 8, 9, 12, 15, 18) THEN t .Amount * - 1 WHEN ch.Id = t .Id THEN ch.UnitPrice WHEN d.DiscountTypeId = 3 THEN d.ConfiguredDiscountAmount  ELSE t .Amount END AS UnitPrice, 
			clj.ArDebit, 
			clj.ArCredit, 
			COALESCE (db.OriginalCreditId, ref.OriginalPaymentId, rd.ReverseChargeId, d.ChargeId, rtax.ReverseChargeId, tax.ChargeId, rc.Id, ch.Id, pay.Id, wo.Id) AS AssociatedId, 
			t.SortOrder AS AssociatedOrder,
			ch.ChargeGroupId,
			t.Amount as Amount,
			spc.StartServiceDateLabel,
			spc.EndServiceDateLabel,
			ch.ProratedUnitPrice,
			ch.RangeQuantity,
			paj.ParentCustomerId
    FROM     dbo.[Transaction] AS t INNER JOIN
                      dbo.Customer AS c ON t.CustomerId = c.Id INNER JOIN
                      Lookup.TransactionType AS tt ON t.TransactionTypeId = tt.Id INNER JOIN
                      dbo.vw_CustomerLedgerJournal AS clj ON t.Id = clj.TransactionId LEFT OUTER JOIN
                      dbo.Debit AS db ON t.Id = db.Id LEFT OUTER JOIN
                      dbo.Credit AS cred ON COALESCE (db.OriginalCreditId, t.Id) = cred.Id LEFT OUTER JOIN
                      dbo.Refund AS ref ON t.Id = ref.Id LEFT OUTER JOIN
                      dbo.Payment AS pay ON t.Id = pay.Id LEFT OUTER JOIN
                      dbo.PaymentActivityJournal AS paj ON COALESCE (pay.PaymentActivityJournalId, ref.PaymentActivityJournalId) = paj.Id LEFT OUTER JOIN
                      Lookup.PaymentMethodType AS pmt ON paj.PaymentMethodTypeId = pmt.Id LEFT OUTER JOIN
                      dbo.PaymentMethod AS pm ON paj.PaymentMethodId = pm.Id LEFT OUTER JOIN
                      dbo.CreditCard AS cc ON pm.Id = cc.Id LEFT OUTER JOIN
                      dbo.AchCard AS acc ON pm.Id = acc.Id LEFT OUTER JOIN
                      dbo.ReverseDiscount AS rd ON t.Id = rd.Id LEFT OUTER JOIN
                      dbo.Discount AS d ON COALESCE (rd.OriginalDiscountId, t.Id) = d.Id LEFT OUTER JOIN
                      dbo.ReverseTax AS rtax ON t.Id = rtax.Id LEFT OUTER JOIN
                      dbo.Tax AS tax ON COALESCE (rtax.OriginalTaxId, t.Id) = tax.Id LEFT OUTER JOIN
                      dbo.TaxRule AS taxr ON tax.TaxRuleId = taxr.Id LEFT OUTER JOIN
                      dbo.ReverseCharge AS rc ON t.Id = rc.Id LEFT OUTER JOIN
                      dbo.Charge AS ch ON COALESCE (tax.ChargeId, d.ChargeId, rc.OriginalChargeId, t.Id) = ch.Id LEFT OUTER JOIN
					  dbo.SubscriptionProductCharge as spc ON spc.Id = ch.Id LEFT OUTER JOIN
                      dbo.WriteOff AS wo ON t.Id = wo.Id LEFT OUTER JOIN
                      dbo.OpeningBalance AS ob ON t.Id = ob.Id LEFT OUTER JOIN
                      dbo.OpeningBalanceAllocation AS oba ON ob.Id = oba.OpeningBalanceId
    WHERE  t.TransactionTypeId in (1,2,3,4,5,7,8,10,11,12,14,15,16,17,18,19,20,21,22,24,25)

GO

