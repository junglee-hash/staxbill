/*********************************************************************************
[]


Inputs:
 @CustomerId bigint,
 @ProductIds nvarchar(max) (pipe delimited product ids),
 @References nvarchar(max) (pipe delimited references)

Work:
Looks for product items for this customer that have one of the provided product id/reference pairs

Outputs:
ProductId, Reference

*********************************************************************************/
CREATE   procedure [dbo].[usp_FindProductItems]
 @CustomerId bigint,
 @ProductIds nvarchar(max),
 @References nvarchar(max)
AS

set transaction isolation level snapshot

SELECT
	pi.ProductId, pi.Reference
FROM 
	ProductItem pi
INNER JOIN
	(SELECT * FROM dbo.Split(@ProductIds, '|')) as pIds ON CAST(pIds.Data as bigint) = pi.ProductId
INNER JOIN
	(SELECT * FROM dbo.Split(@References, '|')) as refs ON refs.Id = pIds.Id
WHERE
	pi.CustomerId = @CustomerId
	AND pi.Reference = refs.Data
	AND pi.StatusId != 2

GO

