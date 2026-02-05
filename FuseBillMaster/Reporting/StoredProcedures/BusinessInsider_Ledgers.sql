
CREATE PROCEDURE [Reporting].[BusinessInsider_Ledgers]
	@AccountId BIGINT
AS
BEGIN
	declare @SQL nvarchar (max)


set nocount on

declare @EndDate Datetime

set @EndDate = convert(date,getutcdate())

select 
convert(varchar(60),c.Id) as FusebillId
,convert(varchar(60),c.Reference ) as Reference
,convert(varchar(60),sum(ArDebit- ArCredit)) as SumAr
 , convert(varchar(60),sum(CashDebit- CashCredit)) as SumCash
 , convert(varchar(60),sum(UnearnedDebit- UnearnedCredit)) as SumUnearned
 , convert(varchar(60),sum(EarnedDebit- EarnedCredit)) as SumEarned
 , convert(varchar(60),sum(WriteOffDebit- WriteOffCredit)) as SumWriteOff
 , convert(varchar(60),sum(TaxesPayableDebit- TaxesPayableCredit)) as SumTaxes
 , convert(varchar(60),sum(DiscountDebit- DiscountCredit)) as SumDiscounts
 , convert(varchar(60),sum(OpeningBalanceDebit- OpeningBalanceCredit)) as SumOpeningBalance
 , convert(varchar(60),sum(CreditDebit- CreditCredit)) as SumCredit
 , convert(varchar(60),sum(UnearnedDiscountDebit- UnearnedDiscountCredit)) as SumUnearnedDiscount
 from customer c with (readpast)
inner join [transaction] t with (readpast) on c.Id = t.customerId
inner join vw_customerledgerjournal clj with (readpast) on t.Id = clj.TransactionId

where c.AccountId = @AccountId and t.createdtimestamp < @EndDate
group by c.Id 
,c.Reference
set nocount off

	
END

GO

