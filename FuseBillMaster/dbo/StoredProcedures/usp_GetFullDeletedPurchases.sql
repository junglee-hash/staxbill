
CREATE PROCEDURE [dbo].[usp_GetFullDeletedPurchases]
	@purchaseIds nvarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @purchases table
	(
	PurchaseId bigint,
	SortOrder INT
	)

	INSERT INTO @purchases (PurchaseId, SortOrder)
	select Data, ROW_NUMBER() OVER (ORDER BY (SELECT 100)) AS [SortOrder]
	from dbo.Split (@purchaseIds,'|') as purchases
	inner join Purchase p on p.Id = purchases.Data
	inner join Customer c on c.Id = p.CustomerId
	And p.IsDeleted = 1

	SELECT p.*
		, p.StatusId as [Status]
		, p.PricingModelTypeId as [PricingModelType]
		, p.EarningTimingIntervalId as [EarningTimingInterval]
		, p.EarningTimingTypeId as [EarningTimingType]
	FROM Purchase p
	INNER JOIN @purchases pp ON p.Id = pp.PurchaseId
	ORDER BY pp.SortOrder

	SELECT ppr.*
	FROM PurchasePriceRange ppr
	INNER JOIN @purchases pp ON ppr.PurchaseId = pp.PurchaseId

	SELECT pd.*
		, pd.DiscountTypeId as [DiscountType]
	FROM PurchaseDiscount pd
	INNER JOIN @purchases pp ON pd.PurchaseId = pp.PurchaseId

	SELECT pc.*
	FROM PurchaseCharge pc
	INNER JOIN @purchases pp ON pp.PurchaseId = pc.PurchaseId

	SELECT prod.*
		, prod.ProductStatusId as [Status]
		, prod.ProductTypeId as [ProductType]
	FROM Product prod
	INNER JOIN Purchase p ON prod.Id = p.ProductId
	INNER JOIN @purchases pp ON p.Id = pp.PurchaseId

	SELECT pcc.*
	FROM PurchaseCouponCode pcc
	INNER JOIN @purchases pp ON pcc.PurchaseId = pp.PurchaseId

	SELECT cc.*
	FROM CouponCode cc
	INNER JOIN PurchaseCouponCode pcc ON cc.Id = pcc.CouponCodeId
	INNER JOIN @purchases pp ON pcc.PurchaseId = pp.PurchaseId

	SELECT pcf.*
	FROM PurchaseCustomField pcf
	INNER JOIN @purchases pp ON pcf.PurchaseId = pp.PurchaseId

	SELECT cf.*
		, cf.DataTypeId as [DataType]
		, cf.StatusId as [Status]
	FROM CustomField cf
	INNER JOIN PurchaseCustomField pcf ON cf.Id = pcf.CustomFieldId
	INNER JOIN @purchases pp ON pcf.PurchaseId = pp.PurchaseId

	SELECT
		pes.*,
		pes.EarningScheduleIntervalId as EarningScheduleInterval
	FROM PurchaseEarningSchedule pes
	INNER JOIN @purchases pp ON pes.PurchaseId = pp.PurchaseId

	SELECT
		ped.*
	FROM PurchaseEarningDiscountSchedule ped
	INNER JOIN PurchaseEarningSchedule pes ON pes.Id = ped.PurchaseEarningScheduleId
	INNER JOIN @purchases pp ON pes.PurchaseId = pp.PurchaseId
END

GO

