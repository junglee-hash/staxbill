CREATE procedure [dbo].[usp_WriteOffReportInvoiceDetailCount]
@AccountId bigint 
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
              convert(date,convert(char(4),DATEPART(year,dateadd(month,-1,  GETUTCDATE()))) + '-'
              + convert(char(2),DATEPART(month,dateadd(month,-1,  GETUTCDATE()))) + '-01')
       from AccountPreference 
       Where Id = @AccountId
       set @UTCEndDateTime = DATEADD(day,-1, DATEADD(month,1,@UTCStartDateTime))
       END

set @SQL = 
'

SELECT
         Count (Distinct wo.InvoiceId) as Count
FROM 
         [Transaction] t
         inner join WriteOff wo
         on t.Id = wo.Id 
         inner join Customer c
         on t.CustomerId = c.Id
WHERE
         c.AccountId = @AccountId
         and t.EffectiveTimestamp >=@UTCStartDateTime
         and t.EffectiveTimestamp < @UTCEndDateTime
         AND c.CurrencyId = @CurrencyId

GROUP BY 
		 wo.Reference
'

exec sp_executesql @SQL, N'@AccountId bigint,@UTCStartDateTime datetime,@UTCEndDateTime datetime,@CurrencyId bigint',@AccountId,@UTCStartDateTime,@UTCEndDateTime,@CurrencyId

GO

