CREATE PROCEDURE [dbo].[usp_GetFullProducts]
	@productIds nvarchar(max),
	@accountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @products table
(
ProductId bigint
)

INSERT INTO @products (ProductId)
select Data from dbo.Split (@productIds,'|') as products
	inner join Product p on p.Id = products.Data
	where p.AccountId =
		CASE WHEN @accountId = 0 THEN
		 p.AccountId
		ELSE
		 @accountId
		End

SELECT p.*
	, ProductTypeId as ProductType
	, ProductStatusId as [Status]
FROM [dbo].[Product] p
INNER JOIN @products pp ON p.Id = pp.ProductId

SELECT otc.*
	, otc.PricingModelTypeId as PricingModelType
	, otc.EarningTimingTypeId as EarningTimingType
	, otc.EarningTimingIntervalId as EarningTimingInterval 
FROM [dbo].[OrderToCashCycle] otc
INNER JOIN [dbo].[Product] p ON otc.Id = p.OrderToCashCycleId
INNER JOIN @products pp ON p.Id = pp.ProductId

SELECT qr.* FROM [dbo].[QuantityRange] qr
INNER JOIN [dbo].[OrderToCashCycle] otc ON otc.Id = qr.OrderToCashCycleId
INNER JOIN [dbo].[Product] p ON otc.Id = p.OrderToCashCycleId
INNER JOIN @products pp ON p.Id = pp.ProductId

SELECT pr.* FROM [dbo].[Price] pr
INNER JOIN [dbo].[QuantityRange] qr ON qr.Id = pr.QuantityRangeId
INNER JOIN [dbo].[OrderToCashCycle] otc ON otc.Id = qr.OrderToCashCycleId
INNER JOIN [dbo].[Product] p ON otc.Id = p.OrderToCashCycleId
INNER JOIN @products pp ON p.Id = pp.ProductId

SELECT pcf.* FROM [dbo].[ProductCustomField] pcf
INNER JOIN @products pp ON pcf.ProductId = pp.ProductId

SELECT cf.*
	, cf.DataTypeId as DataType
	, cf.StatusId as Status
FROM [dbo].[CustomField] cf
INNER JOIN [dbo].[ProductCustomField] pcf ON cf.Id = pcf.CustomFieldId
INNER JOIN @products pp ON pcf.ProductId = pp.ProductId

SELECT gl.*
	, gl.StatusId as [Status]
FROM [dbo].[GLCode] gl
INNER JOIN [dbo].[Product] p ON gl.Id = p.GLCodeId
INNER JOIN @products pp ON p.Id = pp.ProductId

SELECT es.*
	,es.IntervalId as Interval
FROM [dbo].[OrderToCashCycleEarningSchedule] es
INNER JOIN [dbo].[OrderToCashCycle] otc ON otc.Id = es.OrderToCashCycleId
INNER JOIN [dbo].[Product] p ON otc.Id = p.OrderToCashCycleId
INNER JOIN @products pp ON p.Id = pp.ProductId

END

GO

