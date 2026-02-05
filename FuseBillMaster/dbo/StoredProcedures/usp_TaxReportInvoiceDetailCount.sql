CREATE procedure [dbo].[usp_TaxReportInvoiceDetailCount]
@AccountId bigint 
,@TaxRuleId bigint
,@UTCStartDateTime datetime
,@UTCEndDateTime datetime
,@CurrencyId bigint
AS
DECLARE 
       @SQL nvarchar (max)
       ,@RowStart int = 0
       ,@RowEnd int = 10


if @UTCStartDateTime is null or @UTCEndDateTime is null
       BEGIN
       select @UTCStartDateTime = 
              convert(date,convert(char(4),DATEPART(year,dateadd(month,-1, dbo.fn_GetTimezoneTime ( GETUTCDATE(),TimezoneId)))) + '-'
              + convert(char(2),DATEPART(month,dateadd(month,-1, dbo.fn_GetTimezoneTime ( GETUTCDATE(),TimezoneId)))) + '-01')
       from AccountPreference 
       Where Id = @AccountId
       set @UTCEndDateTime = DATEADD(day,-1, DATEADD(month,1,@UTCStartDateTime))
       END


;WITH TaxAmountCharged as
(
SELECT
       c.Id as FusebillId
       ,c.Reference as CustomerId
       ,tx.InvoiceId
       ,SUM(ISNULL(t.Amount,0)) as TaxAmountCharged
FROM 
       [Transaction] t
       inner join Tax tx
       on t.Id = tx.Id
       inner join Customer c
       on t.CustomerId = c.Id
WHERE
       tx.TaxRuleId = @TaxRuleId
       and c.AccountId = @AccountId
       and t.EffectiveTimestamp >= @UTCStartDateTime 
       and t.EffectiveTimestamp < @UTCEndDateTime
       and t.CurrencyId = @CurrencyId
GROUP BY tx.InvoiceId,c.Id,c.Reference
)
,TaxReversals as
(
SELECT
       c.Id as FusebillId
       ,c.Reference as CustomerId
       ,tx.InvoiceId
       ,SUM(ISNULL(t.Amount,0)) as TaxReversals
FROM 
       [Transaction] t
       inner join ReverseTax rtx
       on t.Id = rtx.Id
       inner join Tax tx
       on rtx.OriginalTaxId = tx.Id
       inner join Customer c
       on t.CustomerId = c.Id
WHERE
       tx.TaxRuleId = @TaxRuleId
       and c.AccountId = @AccountId
       and t.EffectiveTimestamp >= @UTCStartDateTime 
       and t.EffectiveTimestamp < @UTCEndDateTime
       and t.CurrencyId = @CurrencyId
GROUP BY tx.InvoiceId,c.Id,c.Reference
)
,VoidTaxReversals as
(
	SELECT
       c.Id as FusebillId
       ,c.Reference as CustomerId
       ,tx.InvoiceId
       ,SUM(ISNULL(t.Amount,0)) as VoidTaxReversals
	FROM 
		   [Transaction] t
		   inner join VoidReverseTax vtx on t.Id = vtx.Id
		   inner join ReverseTax rtx
		   on vtx.OriginalReverseTaxId = rtx.Id
		   inner join Tax tx
		   on rtx.OriginalTaxId = tx.Id
		   inner join Customer c
		   on t.CustomerId = c.Id
	WHERE
		   tx.TaxRuleId = @TaxRuleId
		   and c.AccountId = @AccountId
		   and t.EffectiveTimestamp >= @UTCStartDateTime 
		   and t.EffectiveTimestamp < @UTCEndDateTime
		   and t.CurrencyId = @CurrencyId
	GROUP BY tx.InvoiceId,c.Id,c.Reference
)
SELECT Count(Distinct Invoices) as Count FROM
(
SELECT
       COALESCE(tac.InvoiceId,tr.InvoiceId) as Invoices
FROM
       TaxAmountCharged tac
       full outer join TaxReversals tr	   
       on tac.InvoiceId = tr.InvoiceId
	   full outer join VoidTaxReversals vtr
	   on tac.InvoiceId = vtr.InvoiceId
)Result

GO

