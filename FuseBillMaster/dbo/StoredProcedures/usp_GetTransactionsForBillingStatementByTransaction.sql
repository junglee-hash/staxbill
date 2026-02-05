-- =============================================
-- Author:		dlarkin
-- Create date: 2018-10-29
-- Description:	sproc to generate billing statements by transaction and summary
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetTransactionsForBillingStatementByTransaction]
--declare
	@customerIds nvarchar(max) = '92713',
	@AccountId bigint = 81794,
	@StartDate datetime = '2017-01-01',
	@EndDate datetime = '2022-10-26',
	@IncludeTrackedItems bit = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @customers table
(
CusId bigint
)

INSERT INTO @customers (CusId)
select 
[Data] 
FROM dbo.Split (@customerIds,'|')


SELECT  
	t.*, 
	CASE 
		WHEN tt.ARBalanceMultiplier > 0 THEN t.Amount
		ELSE 0.00
	END AS ArDebit,
	CASE 
		WHEN tt.ARBalanceMultiplier < 0 THEN t.Amount
		ELSE 0.00
	END AS ArCredit,
	dbo.GetTransactionName(t.TransactionTypeId, tt.Name) as TransactionType
 INTO #CustomerTransactions
	FROM [Transaction] t
	INNER JOIN Lookup.TransactionType AS tt ON t.TransactionTypeId = tt.Id
	inner join @customers c on t.CustomerId = c.CusId
	WHERE 
	t.AccountId = @AccountId
	AND t.EffectiveTimestamp >= @StartDate
	AND t.EffectiveTimestamp <= @EndDate
	AND t.TransactionTypeId in (1,2,3,4,5,7,8,10,11,12,14,15,16,17,18,19,20,21,22,24,25, 28, 29, 30, 31, 32)

select 
	CONCAT(CAST(t.Id AS varchar(100)), '-', ABS(CAST(NEWID() AS binary(6)) % 1000) + 1) AS Id,
	t.id as TransactionId,
	t.CustomerId,
	t.AccountId,
	t.EffectiveTimestamp,
	t.TransactionType,
	COALESCE (pmt.Name + ' (' + pm.AccountType + + ISNULL(' ending in ' + ISNULL(cc.MaskedCardNumber, acc.MaskedAccountNumber), '') + ')', pmt.Name) AS [Name],
	COALESCE (t.Description, pay.Reference, ref.Reference) AS [Description],
	COALESCE (ref.Reference, paj.AuthorizationCode) AS Reference,
	1 AS Quantity,
	CASE
		WHEN t.TransactionTypeId = 3 THEN t.Amount 
		ELSE t.Amount * - 1
	END AS UnitPrice,
	t.ArDebit,
	t.ArCredit,
	COALESCE (ref.OriginalPaymentId, pay.Id) AS AssociatedId, 
	t.SortOrder AS AssociatedOrder,
	null as ChargeGroupId,
	t.Amount as Amount,
	null as StartServiceDateLabel,
	null as EndServiceDateLabel,
	null as ProratedUnitPrice,
	null as RangeQuantity,
	paj.ParentCustomerId
from
	#CustomerTransactions t 
	LEFT OUTER JOIN dbo.Refund AS ref ON t.Id = ref.Id 
	LEFT OUTER JOIN dbo.Payment AS pay ON t.Id = pay.Id 
	LEFT OUTER JOIN dbo.PaymentActivityJournal AS paj ON COALESCE (pay.PaymentActivityJournalId, ref.PaymentActivityJournalId) = paj.Id 
	LEFT OUTER JOIN Lookup.PaymentMethodType AS pmt ON paj.PaymentMethodTypeId = pmt.Id 
	LEFT OUTER JOIN dbo.PaymentMethod AS pm ON paj.PaymentMethodId = pm.Id 
	LEFT OUTER JOIN dbo.CreditCard AS cc ON pm.Id = cc.Id 
	LEFT OUTER JOIN dbo.AchCard AS acc ON pm.Id = acc.Id
WHERE t.TransactionTypeId IN (3, 4, 5)

union all


select 
	CONCAT(CAST(t.Id AS varchar(100)), '-', ABS(CAST(NEWID() AS binary(6)) % 1000) + 1) AS Id,
	t.id as TransactionId,
	t.CustomerId,
	t.AccountId,
	t.EffectiveTimestamp,
	t.TransactionType,
	isnull(COALESCE (taxr.Name, ch.Name), t.TransactionType) as [Name],
	COALESCE (CAST(taxr.Percentage AS varchar(10)), t.Description) AS [Description],
	COALESCE (taxr.RegistrationCode, rc.Reference) AS Reference,
	CASE 
		WHEN t.TransactionTypeId IN (1, 20) THEN ch.Quantity 
		WHEN d.DiscountTypeId = 3 THEN d.Quantity 
		ELSE 1 
	END AS Quantity, 
	CASE 
		WHEN t.TransactionTypeId IN (7, 8, 12, 15) THEN t.Amount * - 1 
		WHEN ch.Id = t .Id THEN ch.UnitPrice 
		WHEN d.DiscountTypeId = 3 THEN d.ConfiguredDiscountAmount  
		ELSE t .Amount 
	END AS UnitPrice,	
	t.ArDebit,
	t.ArCredit,
	COALESCE (vrt.OriginalReverseTaxId, vrd.OriginalReverseDiscountId, vrc.OriginalReverseChargeId,rd.ReverseChargeId, d.ChargeId, rtax.ReverseChargeId, tax.ChargeId, rc.Id, ch.Id) AS AssociatedId, 
	t.SortOrder AS AssociatedOrder,
	ch.ChargeGroupId,
	t.Amount as Amount,
	spc.StartServiceDateLabel,
	spc.EndServiceDateLabel,
	ch.ProratedUnitPrice,
	ch.RangeQuantity,
	null as ParentCustomerId
from
	#CustomerTransactions t
	LEFT OUTER JOIN dbo.ReverseDiscount AS rd ON t.Id = rd.Id 
	LEFT OUTER JOIN dbo.Discount AS d ON COALESCE (rd.OriginalDiscountId, t.Id) = d.Id 
	LEFT OUTER JOIN dbo.ReverseTax AS rtax ON t.Id = rtax.Id 
	LEFT OUTER JOIN dbo.Tax AS tax ON COALESCE (rtax.OriginalTaxId, t.Id) = tax.Id 
	LEFT OUTER JOIN dbo.TaxRule AS taxr ON tax.TaxRuleId = taxr.Id 
	LEFT OUTER JOIN dbo.ReverseCharge AS rc ON t.Id = rc.Id 
	LEFT OUTER JOIN dbo.Charge AS ch ON COALESCE (tax.ChargeId, d.ChargeId, rc.OriginalChargeId, t.Id) = ch.Id 
	LEFT OUTER JOIN dbo.SubscriptionProductCharge as spc ON spc.Id = ch.Id 
	left outer join dbo.VoidReverseCharge as vrc on t.Id = vrc.Id
	left outer join dbo.VoidReverseDiscount as vrd on t.Id = vrd.Id
	left outer join dbo.VoidReverseTax as vrt on t.Id = vrt.Id
WHERE t.TransactionTypeId IN (1, 7, 8, 11, 12, 14, 15, 20, 21, 22, 28, 29, 30, 31, 32)


union all


select 
	CONCAT(CAST(t.Id AS varchar(100)), '-', ABS(CAST(NEWID() AS binary(6)) % 1000) + 1) AS Id,
	t.id as TransactionId,
	t.CustomerId,
	t.AccountId,
	t.EffectiveTimestamp,
	t.TransactionType,
	t.TransactionType as [Name],
	COALESCE (t.Description, cred.Reference, ob.Reference) AS Description, 
    wo.Reference AS Reference,
	1 as Quantity,
	CASE 
		WHEN t.TransactionTypeId = 18 THEN t.Amount * - 1  
		ELSE t .Amount 
	END AS UnitPrice,
	t.ArDebit,
	t.ArCredit,
	COALESCE (db.OriginalCreditId, wo.Id) AS AssociatedId, 
	t.SortOrder AS AssociatedOrder,
	null as ChargeGroupId,
	t.Amount as Amount,
	null as StartServiceDateLabel,
	null as EndServiceDateLabel,
	null as ProratedUnitPrice,
	null as RangeQuantity,
	null as ParentCustomerId
from
	#CustomerTransactions t
	LEFT OUTER JOIN dbo.Debit AS db ON t.Id = db.Id 
	LEFT OUTER JOIN dbo.Credit AS cred ON COALESCE (db.OriginalCreditId, t.Id) = cred.Id
	LEFT OUTER JOIN dbo.WriteOff AS wo ON t.Id = wo.Id 
	LEFT OUTER JOIN dbo.OpeningBalance AS ob ON t.Id = ob.Id 	
WHERE t.TransactionTypeId IN (2, 10, 16, 17, 18, 19, 24, 25)



select cpi.* , ct.EffectiveTimestamp
from ChargeProductItem cpi
inner join ProductItem pri on pri.Id = cpi.ProductItemId
inner join Product pro on pro.Id = pri.ProductId
inner join #CustomerTransactions ct on ct.Id = cpi.ChargeId
where pro.AccountId = @AccountId
AND @IncludeTrackedItems = 1

select pri.*,
 pri.StatusId as [Status] 
from ProductItem pri
inner join ChargeProductItem cpi on pri.Id = cpi.ProductItemId
inner join Product pro on pro.Id = pri.ProductId
inner join #CustomerTransactions ct on ct.Id = cpi.ChargeId
where pro.AccountId = @AccountId
and pri.CustomerId = ct.CustomerId
AND @IncludeTrackedItems = 1
order by pri.ModifiedTimestamp desc

drop table #CustomerTransactions

END

GO

