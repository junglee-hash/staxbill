CREATE procedure [dbo].[usp_TaxReportInvoiceDetail]
@AccountId bigint 
,@TaxRuleId bigint
,@UTCStartDateTime datetime
,@UTCEndDateTime datetime
,@SortField varchar (60)
,@SortOrder varchar (4)
,@PageNumber int = 0
,@PageSize int = 10
,@CurrencyId bigint
AS
DECLARE 
       @SQL nvarchar (max)
       ,@RowStart int = 0
       ,@RowEnd int = 10

set @RowStart = @PageSize * @PageNumber +1
set @RowEnd = @RowStart + @PageSize

IF @SortField not in
(
       'FusebillId'
       ,'CustomerId'
       ,'InvoiceId'
       ,'TaxAmountCharged'
       ,'TaxReversals'
       ,'NetTaxCharged'
)
       SET @SortField = 'FusebillId'


IF @SortOrder in
(
       'd'
       ,'Desc'
       ,'Descending'
) set @SortOrder = 'Desc'
ELSE IF @SortOrder is null
       set @SortOrder = 'Desc'
ELSE
       set @SortOrder = 'Asc'

if @UTCStartDateTime is null or @UTCEndDateTime is null
       BEGIN
       select @UTCStartDateTime = 
              convert(date,convert(char(4),DATEPART(year,dateadd(month,-1, dbo.fn_GetTimezoneTime ( GETUTCDATE(),TimezoneId)))) + '-'
              + convert(char(2),DATEPART(month,dateadd(month,-1, dbo.fn_GetTimezoneTime ( GETUTCDATE(),TimezoneId)))) + '-01')
       from AccountPreference 
       Where Id = @AccountId
       set @UTCEndDateTime = DATEADD(day,-1, DATEADD(month,1,@UTCStartDateTime))
       END

set @SQL = 
'
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
       and c.CurrencyId = @CurrencyId
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
       and c.CurrencyId = @CurrencyId
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
       and c.CurrencyId = @CurrencyId
GROUP BY tx.InvoiceId,c.Id,c.Reference
)
SELECT  

       FusebillId
       ,CustomerId
       ,InvoiceId
       ,TaxAmountCharged
       ,TaxReversals
       ,NetTaxCharged
FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY ' +isnull(@SortField,'FusebillId') + ' ' +isnull(@SortOrder,'asc') + ' ) AS RowNum, *
FROM
(
SELECT
       Coalesce(tac.FusebillId,tr.FusebillId) as FusebillId
       ,Coalesce(tac.InvoiceId,tr.InvoiceId) as InvoiceId
       ,Coalesce(tac.CustomerId,tr.CustomerId,'''') as CustomerId
       ,ISNULL(tac.TaxAmountCharged,0) as TaxAmountCharged
       ,isnull(tr.TaxReversals ,0) - isnull(vtr.VoidTaxReversals ,0) as TaxReversals
       ,isnull(tac.TaxAmountCharged,0) - isnull(tr.TaxReversals ,0) + isnull(vtr.VoidTaxReversals ,0) as NetTaxCharged
FROM
       TaxAmountCharged tac
       full outer join TaxReversals tr
       on tac.InvoiceId = tr.InvoiceId   
	   full outer join VoidTaxReversals vtr
	   on tac.InvoiceId = vtr.InvoiceId
       )Result
)RowConstrainedResult
'
set @SQL = @SQL +  '
WHERE   RowNum >= ' + convert(varchar (20), isnull(@RowStart,1)) + '
    AND RowNum < ' +  convert(varchar (20),isnull(@RowEnd,20)) + ' 
ORDER BY RowNum 
'

exec sp_executesql @SQL, N'@AccountId bigint,@TaxRuleId bigint,@UTCStartDateTime datetime,@UTCEndDateTime datetime,@CurrencyId bigint',@AccountId,@TaxRuleId,@UTCStartDateTime,@UTCEndDateTime,@CurrencyId

GO

