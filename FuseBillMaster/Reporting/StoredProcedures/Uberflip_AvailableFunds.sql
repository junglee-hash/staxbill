CREATE PROCEDURE [Reporting].[Uberflip_AvailableFunds]
	@AccountId BIGINT
AS

set nocount on
set transaction isolation level snapshot

select
convert(varchar(60),c.Id) as FusebillId
,isnull(c.reference,'') as CustomerId 
,isnull(c.CompanyName,'') as CompanyName
,af.Type
,convert(varchar(60),sum(af.Amount)) as Amount
,convert(varchar(60),sum(af.Amount - af.UnallocatedAmount)) as AllocatedAmount
,convert(varchar(60),sum(af.UnallocatedAmount)) as AvailableFunds  
,c.ArBalance
from
(
SELECT
	t.Amount
	,p.UnallocatedAmount
	,t.CustomerId
	,'Payment' as Type
FROM Payment p
INNER JOIN [Transaction] t ON t.Id = p.Id
WHERE 
t.AccountId = @AccountId
AND p.UnallocatedAmount > 0
UNION ALL
SELECT
	t.Amount
	,p.UnallocatedAmount
	,t.CustomerId
	,'Credit' as Type
FROM Credit p
INNER JOIN [Transaction] t ON t.Id = p.Id
WHERE 
t.AccountId = @AccountId
AND p.UnallocatedAmount > 0
) af
inner join customer c on af.CustomerId = c.Id
where c.Id not in (
	2019257 -- Multiple partial refunds on cancelled customer BUG 13393
)
group by
	c.Id 
	,isnull(c.reference,'') 
	,isnull(c.CompanyName,'') 
	,af.Type
	,c.ArBalance
ORDER BY FusebillId
set nocount off

GO

