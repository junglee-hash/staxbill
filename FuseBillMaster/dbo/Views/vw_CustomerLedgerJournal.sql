CREATE VIEW [dbo].[vw_CustomerLedgerJournal]
AS

SELECT
pt.Id
,pt.CreatedTimestamp
,pt.TransactionId
,COALESCE(pt.[Accounts Receivable Debits],0) as ArDebit
,COALESCE(pt.[Accounts Receivable Credits],0) as ArCredit
,COALESCE(pt.[Cash Debits],0) as CashDebit
,COALESCE(pt.[Cash Credits],0) as CashCredit
,COALESCE(pt.[Unearned Revenue Debits],0) as UnearnedDebit
,COALESCE(pt.[Unearned Revenue Credits],0) as UnearnedCredit
,COALESCE(pt.[Earned Revenue Debits],0) as EarnedDebit
,COALESCE(pt.[Earned Revenue Credits],0) as EarnedCredit
,COALESCE(pt.[Write Off Debits],0) as WriteOffDebit
,COALESCE(pt.[Write Off Credits],0) as WriteOffCredit
,COALESCE(pt.[Taxes Payable Debits],0) as TaxesPayableDebit
,COALESCE(pt.[Taxes Payable Credits],0) as TaxesPayableCredit
,COALESCE(pt.[Earned Discounts Debits],0) as DiscountDebit
,COALESCE(pt.[Earned Discounts Credits],0) as DiscountCredit
,COALESCE(pt.[Opening Balance Debits],0) as OpeningBalanceDebit
,COALESCE(pt.[Opening Balance Credits],0) as OpeningBalanceCredit
,COALESCE(pt.[Credit Balance Debits],0) as CreditDebit
,COALESCE(pt.[Credit Balance Credits],0) as CreditCredit
,COALESCE(pt.[Unearned Discounts Debits],0) as UnearnedDiscountDebit
,COALESCE(pt.[Unearned Discounts Credits],0) as UnearnedDiscountCredit
,COALESCE(pt.[Opening Deferred Revenue Debits],0) as OpeningDeferredRevenueDebit
,COALESCE(pt.[Opening Deferred Revenue Credits],0) as OpeningDeferredRevenueCredit
,pt.AccountId
,pt.CustomerId
,pt.EffectiveTimestamp
FROM (
SELECT
t.Id
,t.CreatedTimestamp
,t.Id as TransactionId
,t.AccountId
,t.CustomerId
,t.EffectiveTimestamp
,t.Amount
,ttl.PivotColumnName
FROM [transaction] t
INNER JOIN Lookup.TransactionTypeLedger ttl on ttl.TransactionTypeId = t.TransactionTypeId
WHERE t.Amount <> 0
) ds
PIVOT(
    SUM(Amount)
    FOR PivotColumnName IN (
        [Accounts Receivable Credits]
,[Accounts Receivable Debits]
,[Cash Credits]
,[Cash Debits]
,[Credit Balance Credits]
,[Credit Balance Debits]
,[Earned Discounts Credits]
,[Earned Discounts Debits]
,[Earned Revenue Credits]
,[Earned Revenue Debits]
,[Opening Balance Credits]
,[Opening Balance Debits]
,[Opening Deferred Revenue Debits]
,[Opening Deferred Revenue Credits]
,[Taxes Payable Credits]
,[Taxes Payable Debits]
,[Unearned Discounts Credits]
,[Unearned Discounts Debits]
,[Unearned Revenue Credits]
,[Unearned Revenue Debits]
,[Write Off Debits]
,[Write Off Credits])
) AS pt;

GO

