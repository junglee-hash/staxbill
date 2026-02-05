CREATE procedure [dbo].[usp_WriteOffReportInvoiceDetail]
@AccountId bigint 
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
       ,'WriteOffAmount'
	   ,'WriteOffReference'
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
SELECT  

       FusebillId
       ,CustomerId
       ,InvoiceId
       ,WriteOffAmount
	   ,WriteOffReference
FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY ' +isnull(@SortField,'FusebillId') + ' ' +isnull(@SortOrder,'asc') + ' ) AS RowNum, *
FROM
(
SELECT
       c.Id as FusebillId
       ,isnull(c.Reference,'''') as CustomerId
       ,wo.InvoiceId
       ,sum(t.Amount) as WriteOffAmount
       ,wo.Reference as WriteOffReference
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
       and c.CurrencyId = @CurrencyId
GROUP BY 
       c.Id 
       ,c.Reference 
       ,wo.InvoiceId
	   ,wo.Reference

)Result
)RowConstrainedResult
'
set @SQL = @SQL +  '
WHERE   RowNum >= ' + convert(varchar (20), isnull(@RowStart,1)) + '
    AND RowNum < ' +  convert(varchar (20),isnull(@RowEnd,20)) + ' 
ORDER BY RowNum 
'

exec sp_executesql @SQL, N'@AccountId bigint,@UTCStartDateTime datetime,@UTCEndDateTime datetime,@CurrencyId bigint',@AccountId,@UTCStartDateTime,@UTCEndDateTime,@CurrencyId

GO

