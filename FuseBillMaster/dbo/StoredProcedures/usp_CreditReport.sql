
/*
declare 
@AccountId bigint = 10
,@CurrencyId bigint = 1
,@UTCStartDateTime datetime = '2014-01-01 5:00:00'
,@UTCEndDateTime datetime = getutcdate()
,@SortField varchar (60) = 'Amount'
	,@SortOrder varchar (4) = 'Asc'
	,@PageNumber int = 0
	,@PageSize int = 100

exec usp_CreditReport @AccountId ,@CurrencyId,@UTCStartDateTime,@UTCEndDateTime,@SortField ,@SortOrder,@PageNumber,@PageSize  

*/


CREATE Procedure [dbo].[usp_CreditReport]
	@AccountId bigint
	,@CurrencyId bigint = 1
	,@UTCStartDateTime datetime
	,@UTCEndDateTime datetime
	,@SortField varchar (60) = 'FusebillId'
	,@SortOrder varchar (4) = 'Asc'
	,@PageNumber int = 0
	,@PageSize int = 25
AS

Declare 
	@SQL nvarchar(max)
	,@RowStart int = 0
    ,@RowEnd int = 10

IF @PageNumber is NULL 
 set @PageNumber = 0

IF @PageSize is NULL OR @PageSize = 0
 set @PageSize = 10 

set @RowStart = @PageSize * @PageNumber 
set @RowEnd = @PageSize

IF @SortField not in
(
	'FusbillId'
	,'CustomerId'
	,'Date'
	,'CreditLineItemDescription'
	,'Amount'
) or @SortField is null or @SortField = 'FusebillId'
       SET @SortField = 'FusebillId'

select @UTCStartDateTime = coalesce (@UTCStartDateTime,GETUTCDATE())
select @UTCEndDateTime = coalesce (@UTCEndDateTime,dateadd(month,-1,GETUTCDATE()))

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


set @SQL = 'select 
	c.Id as FusebillId
	,isnull(c.Reference,'''') as CustomerId
	,dbo.fn_getTimezoneTime(t.EffectiveTimestamp,a.TimezoneId) as EffectiveTimestamp
	,coalesce(cr.Reference,rc.Reference,'''') as CreditLineItemDescription
	,t.Amount * ARBalanceMultiplier  as Amount
from 
	[Transaction] t 
	inner join Customer c 
	on t.CustomerId = c.Id 
	inner join AccountPreference a
	on c.AccountId = a.Id
	left join Credit cr
	on t.Id = cr.Id
	inner join Lookup.TransactionType tt
	on t.TransactionTypeId = tt.Id
	left join Debit rc
	on t.Id = rc.Id

where 
	c.AccountId = @AccountId
	and c.CurrencyId = @CurrencyId
	and t.EffectiveTimestamp >=@UTCStartDateTime 
	and t.EffectiveTimestamp < @UTCEndDateTime 
	and t.transactionTypeId in (17,18)
Order by '
set @sql = @Sql  + @SortField + ' ' + @SortOrder + ' '



set @SQL = @SQL +  '
Offset '+ convert(varchar(60),@RowStart) + ' Rows
FETCH NEXT ' + Convert(varchar(60),@RowEnd) + ' ROWS ONLY;
'
exec sp_executesql @SQL, N'@AccountId bigint,@CurrencyId bigint, @UTCStartDateTime datetime,@UTCEndDateTime datetime,@SortField varchar (60),@SortOrder varchar (4),@PageNumber int,@PageSize int',@AccountId ,@CurrencyId,@UTCStartDateTime,@UTCEndDateTime,@SortField ,@SortOrder,@PageNumber,@PageSize

GO

