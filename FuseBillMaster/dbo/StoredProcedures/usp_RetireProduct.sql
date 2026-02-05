CREATE procedure [dbo].[usp_RetireProduct]
	@ProductId bigint,
	@AccountId bigint	
AS

SET NOCOUNT ON

declare @ProductStatusId int
select @ProductStatusId = (select top 1 id from Lookup.ProductStatus where [name] = 'Retired')

declare @PlanProductStatusId int
select @PlanProductStatusId = (select top 1 id from Lookup.PlanProductStatus where [name] = 'Retired')

Update Product
	set ProductStatusId = @ProductStatusId 
	where Id = @ProductId and AccountId = @AccountId

Update pp
	set StatusId = @PlanProductStatusId
	from PlanProduct pp inner join
	Product p on pp.ProductId = p.Id
	Where ProductId = @ProductId and AccountId = @AccountId

delete pp
from HostedPageManagedOfferingProduct pp
inner join
	Product p on pp.ProductId = p.Id
	Where ProductId = @ProductId and AccountId = @AccountId

Select @ProductId AS ProductId

SET NOCOUNT OFF

GO

