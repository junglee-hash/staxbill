
/*********************************************************************************
[]


Inputs:
 @CustomerId bigint,
 @ProductIds nvarchar(max) (pipe delimited product ids),
 @References nvarchar(max) (pipe delimited references)

Work:
Looks for subscription products for this customer that have subscription product item with one of the provided product id/reference pairs

Outputs:
ProductId, Reference, SubscriptionProductId

*********************************************************************************/
CREATE procedure [dbo].[usp_FindSubscriptionProductItems]
 @CustomerId bigint,
 @ProductIds nvarchar(max),
 @References nvarchar(max)
AS

SELECT
	pi.ProductId, pi.Reference, sp.Id as SubscriptionProductId
FROM 
	SubscriptionProductItem spi
INNER JOIN
	ProductItem pi ON pi.Id = spi.Id
INNER JOIN
	SubscriptionProduct sp ON sp.Id = spi.SubscriptionProductId
INNER JOIN
	Subscription s ON s.Id = sp.SubscriptionId
INNER JOIN
	(SELECT * FROM dbo.Split(@ProductIds, '|')) as pIds ON CAST(pIds.Data as bigint) = pi.ProductId
INNER JOIN
	(SELECT * FROM dbo.Split(@References, '|')) as refs ON refs.Id = pIds.Id
WHERE
	s.CustomerId = @CustomerId
	AND pi.Reference = refs.Data

GO

