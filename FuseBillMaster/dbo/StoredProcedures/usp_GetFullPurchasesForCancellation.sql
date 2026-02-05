
CREATE PROCEDURE [dbo].[usp_GetFullPurchasesForCancellation]
--declare
	@purchaseIds nvarchar(max),
	@AccountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @purchases table
	(
	PurchaseId bigint
	)

	INSERT INTO @purchases (PurchaseId)
	select Data from dbo.Split (@purchaseIds,'|') as purchases
	inner join Purchase p on p.Id = purchases.Data
	inner join Customer c on c.Id = p.CustomerId
	where c.AccountId = @AccountId
	And p.IsDeleted = 0
	And c.IsDeleted = 0

	SELECT p.*
		, p.StatusId as [Status]
		, p.PricingModelTypeId as [PricingModelType]
		, p.EarningTimingIntervalId as [EarningTimingInterval]
		, p.EarningTimingTypeId as [EarningTimingType]
	FROM Purchase p
	INNER JOIN @purchases pp ON p.Id = pp.PurchaseId

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

  SELECT * FROM DraftPurchaseCharge dpc
  INNER JOIN @purchases pp ON dpc.PurchaseId = pp.PurchaseId

  SELECT dc.*
	, dc.TransactionTypeId as TransactionType
	, dc.StatusId as [Status]
	, dc.EarningTimingTypeId as EarningTimingType
	, dc.EarningTimingIntervalId as EarningTimingInterval
  FROM DraftPurchaseCharge dpc
  INNER JOIN DraftCharge dc ON dc.Id = dpc.Id
  INNER JOIN @purchases pp ON dpc.PurchaseId = pp.PurchaseId

  SELECT c.*
		, t.*
		, c.EarningTimingTypeId as EarningTimingType
		, c.EarningTimingIntervalId as EarningTimingInterval
		, t.TransactionTypeId as TransactionType
	FROM [dbo].[Charge] c
	INNER JOIN [Transaction] t ON t.Id = c.Id
	INNER JOIN PurchaseCharge pc ON pc.Id = c.Id
	INNER JOIN @purchases pp ON pp.PurchaseId = pc.PurchaseId

	SELECT dd.*
	 , dd.DiscountTypeId as DiscountType    
	 , dd.TransactionTypeId as TransactionType 
	FROM [dbo].[DraftDiscount] dd    
	INNER JOIN DraftCharge dc ON dd.DraftChargeId = dc.Id
	INNER JOIN DraftPurchaseCharge dpc ON dpc.Id = dc.Id
	INNER JOIN @purchases pp ON dpc.PurchaseId = pp.PurchaseId
    
	SELECT dt.*
	FROM [dbo].[DraftTax] dt    
	INNER JOIN DraftCharge dc ON dt.DraftChargeId = dc.Id
	INNER JOIN DraftPurchaseCharge dpc ON dpc.Id = dc.Id
	INNER JOIN @purchases pp ON dpc.PurchaseId = pp.PurchaseId
    
	SELECT dcpi.*    
	FROM [dbo].[DraftChargeProductItem] dcpi    
	INNER JOIN DraftCharge dc ON dcpi.DraftChargeId = dc.Id
	INNER JOIN DraftPurchaseCharge dpc ON dpc.Id = dc.Id
	INNER JOIN @purchases pp ON dpc.PurchaseId = pp.PurchaseId
    
	SELECT DISTINCT ds.*    
	FROM [dbo].[DraftPaymentSchedule] ds    
	INNER JOIN DraftCharge dc on dc.DraftInvoiceId = ds.DraftInvoiceId
	INNER JOIN DraftPurchaseCharge dpc ON dpc.Id = dc.Id
	INNER JOIN @purchases pp ON dpc.PurchaseId = pp.PurchaseId
  
	SELECT DISTINCT celdi.Id, celdi.CustomerEmailLogId, celdi.DraftInvoiceId  
	FROM draftinvoice di   
	JOIN DraftCharge dc ON di.id = dc.DraftInvoiceId  
	JOIN CustomerEmailLogDraftInvoice celdi ON celdi.DraftInvoiceId = di.Id  
	INNER JOIN DraftPurchaseCharge dpc ON dpc.Id = dc.Id
	INNER JOIN @purchases pp ON dpc.PurchaseId = pp.PurchaseId

	SELECT DISTINCT d.*    
	 , DraftInvoiceStatusId as DraftInvoiceStatus    
	FROM [dbo].[DraftInvoice] d    
	INNER JOIN DraftCharge dc on dc.DraftInvoiceId = d.Id
	INNER JOIN DraftPurchaseCharge dpc ON dpc.Id = dc.Id
	INNER JOIN @purchases pp ON dpc.PurchaseId = pp.PurchaseId

END

GO

