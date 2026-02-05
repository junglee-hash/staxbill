CREATE PROCEDURE [dbo].[usp_GetFullPricebooks]
	@pricebookIds  AS dbo.IDList READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


SELECT p.*
FROM [dbo].[Pricebook] p
INNER JOIN @pricebookIds pp ON p.Id = pp.Id

SELECT pe.*
FROM [dbo].[PricebookEntry] pe
INNER JOIN @pricebookIds pp ON pe.PricebookId = pp.Id

SELECT otc.*
	, otc.PricingModelTypeId as PricingModelType
	, otc.EarningTimingTypeId as EarningTimingType
	, otc.EarningTimingIntervalId as EarningTimingInterval 
FROM [dbo].[OrderToCashCycle] otc
INNER JOIN [dbo].[PricebookEntry] pe ON otc.Id = pe.OrderToCashCycleId
INNER JOIN @pricebookIds pp ON pe.PricebookId = pp.Id

SELECT qr.* FROM [dbo].[QuantityRange] qr
INNER JOIN [dbo].[OrderToCashCycle] otc ON otc.Id = qr.OrderToCashCycleId
INNER JOIN [dbo].[PricebookEntry] pe ON otc.Id = pe.OrderToCashCycleId
INNER JOIN @pricebookIds pp ON pe.PricebookId = pp.Id

SELECT pr.* FROM [dbo].[Price] pr
INNER JOIN [dbo].[QuantityRange] qr ON qr.Id = pr.QuantityRangeId
INNER JOIN [dbo].[OrderToCashCycle] otc ON otc.Id = qr.OrderToCashCycleId
INNER JOIN [dbo].[PricebookEntry] pe ON otc.Id = pe.OrderToCashCycleId
INNER JOIN @pricebookIds pp ON pe.PricebookId = pp.Id

SELECT pe.*
FROM [dbo].[PricebookMaxPrice] pe
INNER JOIN @pricebookIds pp ON pe.PricebookId = pp.Id


END

GO

