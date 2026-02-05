CREATE   PROCEDURE [dbo].[usp_GetPricedProducts]
	@productIds AS dbo.IDList READONLY
AS
BEGIN

set transaction isolation level snapshot

-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT *
      ,[ProductTypeId] as ProductType
      ,[ProductStatusId] as Status
  FROM [dbo].[Product] p 
  INNER JOIN @productIds pp ON p.Id = pp.Id
  WHERE p.AvailableForPurchase = 1

SELECT occ.*
      ,[PricingModelTypeId] as PricingModelType
      ,[EarningTimingTypeId] as EarningTimingType
      ,[EarningTimingIntervalId] as EarningTimingInterval
  FROM [dbo].[OrderToCashCycle] occ
  INNER JOIN Product p ON occ.Id = p.OrderToCashCycleId
  INNER JOIN @productIds pp ON p.Id = pp.Id
  WHERE p.AvailableForPurchase = 1

  SELECT qr.* FROM QuantityRange qr
  INNER JOIN Product p ON qr.OrderToCashCycleId = p.OrderToCashCycleId
  INNER JOIN @productIds pp ON p.Id = pp.Id
  WHERE p.AvailableForPurchase = 1

  SELECT pr.* FROM Price pr
  INNER JOIN QuantityRange qr ON qr.Id = pr.QuantityRangeId
  INNER JOIN Product p ON qr.OrderToCashCycleId = p.OrderToCashCycleId
  INNER JOIN @productIds pp ON p.Id = pp.Id
  WHERE p.AvailableForPurchase = 1

  SELECT pcf.* FROM ProductCustomField pcf
  INNER JOIN Product p ON p.Id= pcf.ProductId
  INNER JOIN @productIds pp ON p.Id = pp.Id
  WHERE p.AvailableForPurchase = 1

SELECT cf.*
	,[DataTypeId] as DataType
	,[StatusId] as Status
  FROM CustomField cf
  INNER JOIN ProductCustomField pcf ON cf.Id = pcf.CustomFieldId
  INNER JOIN Product p ON p.Id= pcf.ProductId
  INNER JOIN @productIds pp ON p.Id = pp.Id
  WHERE p.AvailableForPurchase = 1
END

GO

