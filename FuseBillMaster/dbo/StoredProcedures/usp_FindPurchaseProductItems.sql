
/*********************************************************************************
[]


Inputs:
 @CustomerId bigint,
 @ProductIds nvarchar(max) (pipe delimited product ids),
 @References nvarchar(max) (pipe delimited references)

Work:
Looks for purchases for this customer that have purchase product item with one of the provided product id/reference pairs

Outputs:
ProductId, Reference, PurchaseId

*********************************************************************************/
CREATE procedure [dbo].[usp_FindPurchaseProductItems]
 @CustomerId bigint,
 @ProductIds nvarchar(max),
 @References nvarchar(max)
AS

SELECT
	pi.ProductId, pi.Reference, sp.Id as PurchaseId
FROM 
	PurchaseProductItem spi
INNER JOIN
	ProductItem pi ON pi.Id = spi.Id
INNER JOIN
	Purchase sp ON sp.Id = spi.PurchaseId
INNER JOIN
	(SELECT * FROM dbo.Split(@ProductIds, '|')) as pIds ON CAST(pIds.Data as bigint) = pi.ProductId
INNER JOIN
	(SELECT * FROM dbo.Split(@References, '|')) as refs ON refs.Id = pIds.Id
WHERE
	sp.CustomerId = @CustomerId
	AND pi.Reference = refs.Data

GO

