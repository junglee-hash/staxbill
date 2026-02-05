
CREATE   FUNCTION [dbo].[AllCustomerDescendants]
(	
	@ParentCustomerId AS BIGINT
)
RETURNS TABLE 
AS
RETURN 
(
	with cte as (
		select id, ParentId from Customer
		where Id = @ParentCustomerId
		union all
		select child.Id, child.ParentId from Customer child
		join cte parent
		on parent.Id = child.ParentId
	)

	select Id, ParentId 
	from cte
	
)

GO

