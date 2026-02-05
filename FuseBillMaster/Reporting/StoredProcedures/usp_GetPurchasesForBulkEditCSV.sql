CREATE PROCEDURE [Reporting].[usp_GetPurchasesForBulkEditCSV]  
--declare  
 @AccountId bigint,
 @ProductIds AS dbo.IDList READONLY
AS  
BEGIN  
 SET NOCOUNT ON;  

 DECLARE @ProductIdCount int 
 SET @ProductIdCount = (SELECT COUNT(*) FROM @ProductIds)

	SELECT
		'Mandatory - Unique ID of purchase being edited' as PurchaseId
		, 'Informational - Unique ID of customer that purchase exists on' as StaxBillId
		, 'Informational - Customer Reference of customer that purchase exists on' as CustomerReference
		, 'Informational - Customer Company Name of customer that purchase exists on' as CustomerCompanyName
		, 'Informational - Product Code from catalog source of purchase' as ProductCode
		, 'Optional - Purchase Name (Maximum length of 2000 characters. Overrides the Purchase Name)' as PurchaseName
		, 'Optional - Purchase Description (Maximum length of 2000 characters. Overrides the Purchase Description)' as PurchaseDescription
		, 'Optional - Purchase Quantity (Overrides the default Purchase Quantity. Must be empty for products that track unique quantities)' as PurchaseQuantity
		, 'Optional - Purchase Price (Overrides the catalog price with a Standard Price Specified)' as PurchasePrice
	UNION ALL
	SELECT 
		CAST(p.Id as VARCHAR(25)) as PurchaseId
		, CAST(c.Id as VARCHAR(25)) as StaxBillId
		, c.Reference as CustomerReference
		, c.CompanyName as CustomerCompanyName
		, pp.Code as ProductCode
		, p.Name as PurchaseName
		, p.Description as PurchaseDescription
		, CASE WHEN p.IsTrackingItems = 1 THEN '' ELSE CAST(p.Quantity as VARCHAR(25)) END as PurchaseQuantity
		, CASE WHEN p.PricingModelTypeId = 1 THEN CAST(ppr.Amount as VARCHAR(25)) ELSE 'Varies' END as PurchasePrice
	FROM Purchase p
	INNER JOIN PurchasePriceRange ppr ON p.Id = ppr.PurchaseId
	INNER JOIN Customer c ON c.Id = p.CustomerId
		AND c.AccountId = @AccountId
		AND c.StatusId IN (1, 2) -- Draft or active
	INNER JOIN Product pp ON pp.Id = p.ProductId
	WHERE p.StatusId = 1 -- Draft
		AND (EXISTS (SELECT 1 FROM @ProductIds pp WHERE pp.Id = p.ProductId)
		OR (0 = @ProductIdCount)
	)
	GROUP BY p.Id, c.Id, c.Reference, c.CompanyName, pp.Code, p.Name, p.Description, p.Quantity, p.IsTrackingItems, p.PricingModelTypeId, ppr.Amount

END

GO

