/*
declare
@AccountId bigint
, @CustomerId bigint
, @ProductIds  nvarchar(max)
,@RequestNumberList nvarchar(max)
, @CustomFieldKeys nvarchar(max)
, @CustomFieldValues nvarchar(max)
, @Operators nvarchar(max)

SET @AccountId = 19
SET @CustomerId = 1
Set @RequestNumberList = '1|1|1|2|2'
SET @ProductIds = '39|39|39|40|40'
SET @CustomFieldKeys = 'ProductMeta|StartDate|EndDate|StartDate|EndDate'
SET @CustomFieldValues = '%DWN%|2014/06/08|2014-06-08|2014/05/08|2014-06-09'
SET @Operators = 'like|<=|>=|>|<'

select
@AccountId=10012
,@CustomerId=39913
,@RequestNumberList ='1|1|2|2|3|3|4|4|5|5|6|6|7|7|8|8|9|9|10|10|11|11|12|12|13|13|14|14|15|15|16|16|17|17|18|18|19|19|20|20|21|21|22|22|23|23|24|24|25|25|26|26|27|27|28|28|29|29|30|30|31|31|32|32|33|33|34|34|35|35|36|36|37|37|38|38|39|39|40|40|41|41|42|42|43|43|44|44|45|45|46|46|47|47|48|48|49|49|50|50|51|51|52|52|53|53|54|54|55|55|56|56|57|57|58|58|59|59|60|60|61|61|62|62|63|63|64|64|65|65|66|66|67|67|68|68|69|69|70|70|71|71|72|72|73|73|74|74|75|75|76|76|77|77|78|78|79|79|80|80'
,@ProductIds='31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789|31789'
,@CustomFieldKeys=N'MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld|MetaData|StringFIeld'
,@CustomFieldValues=N'%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%|%aa%|%as%'
,@Operators=N'LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE|LIKE'

exec usp_FindSubscriptionProductByCustomFields @AccountId , @CustomerId,@RequestNumberList , @ProductIds , @CustomFieldKeys , @CustomFieldValues , @Operators 
*/

CREATE   procedure [dbo].[usp_FindSubscriptionProductByCustomFields]
@AccountId bigint
, @CustomerId bigint
, @RequestNumberList nvarchar(max)
, @ProductIds nvarchar(max)
, @CustomFieldKeys nvarchar(max)
, @CustomFieldValues nvarchar(max)
, @Operators nvarchar(max)
as
set transaction isolation level snapshot

set nocount on

DECLARE @CustomFieldSearch AS TABLE
(
       CustomFieldId bigint,
       [Key] nvarchar(255),
       Operator nvarchar(5),
       StringValue nvarchar(1000), 
       NumericValue decimal(18,6),
       DateValue datetime
)

declare @FieldKeys table
(
Id bigint
,Keys nvarchar (max)
)

declare @FieldValues table
(
Id bigint
,Value nvarchar (max)
,FieldName nvarchar (max)
,CustomFieldId bigint 
,ProductId bigint
,Operator nvarchar(max)
)

declare @FieldOperators table
(
Id bigint
,Operators nvarchar (max)
)

declare @FieldProducts table
(
Id bigint
,ProductIds nvarchar (max)
)

declare @FieldRequestNumbers table
(
Id bigint
,RequestNumber nvarchar (max)
)

insert into @FieldKeys (Id, Keys )
select * from dbo.Split (@CustomFieldKeys,'|')

insert into @FieldValues (Id, Value )
select * from dbo.Split (@CustomFieldValues,'|')

insert into @FieldOperators (Id, Operators  )
select * from dbo.Split (@Operators,'|')

insert into @FieldProducts (Id, ProductIds  )
select * from dbo.Split (@ProductIds,'|')

insert into @FieldRequestNumbers  (Id, RequestNumber   )
select * from dbo.Split (@RequestNumberList ,'|')


update @FieldValues set FieldName = 

       CASE WHEN cf.DataTypeId = 1 THEN 'StringValue'
       WHEN cf.DataTypeId = 2 THEN  'NumericValue'
       WHEN cf.DataTypeId = 3 THEN 'DateValue' END
, Value  = '''' +
       case when Operators in( '*','LIKE') and left(fv.value ,1) <>'%' then '%' else '' END + 
       -- if date time, convert date into account timezone in utc
       case when cf.DataTypeId = 3 THEN convert(varchar(100),dbo.fn_GetUtcTime(value, ap.TimezoneId )) else convert(varchar(100), value ) end + 
       case when Operators in( '*','LIKE') and right(value ,1) <>'%' then '%' else '' END +''''--End
,CustomFieldId = cf.Id
,ProductId = fp.ProductIds 
,Operator = case when fo.Operators = '*' then 'LIKE' Else fo.Operators END
from @FieldValues fv
inner join @FieldKeys fk
on fv.Id = fk.Id
inner join CustomField cf
on fk.Keys = cf.[Key] 
inner join AccountPreference ap ON ap.Id = cf.AccountId
inner join @FieldProducts fp
on fv.Id = fp.Id
inner join @FieldOperators fo
on fv.Id = fo.Id
where cf.AccountId = @AccountId 

Declare @Results table
(
       SubscriptionProductId bigint
       , RequestNumber int
)

declare @SQL nvarchar(max)

declare @QueryBuildRequiredFields table
(
ProductId nvarchar(max)
,CustomFieldId nvarchar(max)
,FieldName nvarchar(max)
,Operator nvarchar(max)
,Value nvarchar(max)
,RequestNumber int
)

insert into @QueryBuildRequiredFields
(
ProductId 
,CustomFieldId 
,FieldName 
,Operator
,Value 
,RequestNumber 
)
select 
convert(varchar(100),fv.ProductId), convert(nvarchar(100),fv.CustomFieldId ) , fv.FieldName,convert(nvarchar(100), fv.Operator ) ,convert(nvarchar(100),fv.Value ) ,RequestNumber
from 

          PlanProductFrequencyCustomField spcf with (nolock)
          inner join @FieldValues fv 
          on spcf.CustomFieldId = fv.CustomFieldId
       inner join @FieldRequestNumbers frn
       on fv.id = frn.Id 
group by 
       spcf.CustomFieldId
       ,fv.CustomFieldId
       ,fv.FieldName
       ,fv.Operator
       ,fv.Value
       ,fv.ProductId 
          ,RequestNumber

declare @ReadyForResults table
(
Id int identity (1,1)
,SelectQuery nvarchar(max)
)
insert into 
@ReadyForResults (SelectQuery)
select '
SELECT
       sp.Id as SubscriptionProductId,' + Convert(nvarchar(100),qb.RequestNumber) + ' as RequestId
FROM
       SubscriptionProductCustomField spcf with (nolock)
INNER JOIN
       SubscriptionProduct sp with (nolock)
          ON sp.Id = spcf.SubscriptionProductId
INNER JOIN
       Subscription s with (nolock)
          ON s.Id = sp.SubscriptionId
WHERE
       s.CustomerId = @CustomerId
       AND s.StatusId = 2
       AND sp.StatusId = 1
       AND ( ' 
+ STUFF((SELECT
' ( sp.ProductId = '+convert(varchar(100),qbr.ProductId) +' and spcf.CustomFieldId = ' + convert(nvarchar(100),qbr.CustomFieldId )  + ' and spcf.' + qbr.FieldName +' ' +convert(nvarchar(100), qbr.Operator ) +' ' + convert(nvarchar(100),qbr.Value ) + ' ) or ' from @QueryBuildRequiredFields qbr where qbr.RequestNumber = qb.RequestNumber
FOR XML PATH(''), root('MyString'), type 
     ).value('/MyString[1]','varchar(max)') ,1,1,'')
+' 1 = 2 ) group by sp.Id having count(sp.Id) = ' + convert(varchar(10),(SELECT count (distinct fv.CustomFieldId) from @FieldValues fv inner join @FieldRequestNumbers frn on fv.id = frn.Id  where frn.RequestNumber = qb.RequestNumber))
from @QueryBuildRequiredFields qb
GROUP BY 
 qb.RequestNumber
order by qb.RequestNumber


SELECT @SQL = '
' +  COALESCE( @SQL + ' union all ', '') +  SelectQuery 
FROM 
@ReadyForResults

SELECT @SQL = 'set transaction isolation level snapshot ' + @SQL + ' OPTION (RECOMPILE)'

insert into @Results 
exec sp_executesql @SQL, N'@CustomerId bigint', @CustomerId
select SubscriptionProductId , RequestNumber from @Results 
set nocount off

GO

