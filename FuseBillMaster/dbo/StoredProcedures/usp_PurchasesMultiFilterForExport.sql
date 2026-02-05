
CREATE   PROCEDURE [dbo].[usp_PurchasesMultiFilterForExport]     
 --DECLARE    
 @AccountId bigint,     
 @purchaseIds AS [dbo].[IdListSorted] ReadOnly,
 @IncludeCustomFields bit
AS    
BEGIN    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
SET NOCOUNT ON;    

Declare @TimezoneId int  
  
select @TimezoneId = ad.TimezoneId   
from AccountPreference ad   
where ad.Id = @AccountId  
  
SELECT * INTO #CustomerData  
FROM dbo.BasicCustomerDataByAccount(@AccountId)
--Create temporary table to store summarized values  
create table #PurchaseTempTable  
(  
	ID bigint,    
	SortOrder bigint, 
	[Name] nvarchar(2000) null,
	[Purchase Code] nvarchar(1000) null,
	[Description] nvarchar(2000) null,
	Discounts decimal(18,6) null,    
	[Purchase Net Amount] decimal(18,6),   
	[Purchase Creation Date] DateTime,   
	CustomerId bigint,  
	AccountId bigint,  
	[Posted Invoice Number] bigint null,  
	Currency varchar(50) null,  
	[Purchase Cancellation Timestamp] datetime,  
	[Purchase Finalization Date] datetime,  
	[Date Paid] datetime null,
	[Purchase status] nvarchar(50) null,
	[Posted Invoice Status] nvarchar(50) null,
	[Invoice Owner CustomerId] bigint null,
	[Product Name] nvarchar(100) null,
	[Product Description] nvarchar(1000) null,
	Quantity decimal(18,6) null,
	[Tracking Unique Quantities] varchar(3) null,
	[Default Quantity] decimal(18,6) null,
	[Pricing Model] varchar(50) null,
	[Coupons] nvarchar(255) null,
	[Pending Charges] decimal(18,6) null,
	[Use Billing Address As Shipping Address] varchar(3) null,
	[Contact Name] nvarchar(100) null,
	[Shipping Instructions] nvarchar(1000) null,
	[Billing Company Name] nvarchar(255) null,
	[Billing Line 1] nvarchar(255) null,
	[Billing Line 2] nvarchar(255) null,
	[Billing City] nvarchar(50) null,
	[Billing Country] varchar(255) null,
	[Billing County] nvarchar(150) null,
	[Billing State] nvarchar(255) null,
	[Billing Postal Zip] nvarchar(10) null,
	[Shipping Company Name] nvarchar(1000) null,
	[Shipping Line 1] nvarchar(255) null,
	[Shipping Line 2] nvarchar(255) null,
	[Shipping City] nvarchar(50) null,
	[Shipping Country] nvarchar(150) null,
	[Shipping State] nvarchar(255) null,
	[Shipping Postal Zip] nvarchar(10) null,
	[Shipping County] nvarchar(150) null
);  

WITH PurchaseDiscounts AS
(
SELECT
p.Id as PurchaseId
,p.Amount as GrossAmount
,SUM(CASE WHEN pd.DiscountTypeId = 1 THEN pd.Amount * p.Amount / 100
WHEN pd.DiscountTypeId = 2 THEN pd.Amount
WHEN pd.DiscountTypeId = 3 THEN pd.Amount * p.Quantity
END) as TotalDiscount
FROM PurchaseDiscount pd
INNER JOIN Purchase p ON p.Id = pd.PurchaseId
GROUP BY p.Id,p.Amount
),
--calculate discount per purchase 
PurchaseCharges  
AS (  
 Select pi.Id, Sum(chrg.UnitPrice * chrg.Quantity) as [Pending Charges] from @PurchaseIds  pi   
 INNER JOIN DraftPurchaseCharge purchg on purchg.PurchaseId = pi.Id
 INNER JOIN DraftCharge chrg on chrg.id = purchg.id
 group by pi.Id  
), 

PurchaseDetails  
AS (    
 Select   
		pur.Id,
        pur.[Name],
        prod.Code AS ProductCode,
        dbo.fn_GetTimezoneTime(pur.PurchaseTimestamp, ap.TimezoneId) AS FinalizationDate,
        dbo.fn_GetTimezoneTime(pur.CreatedTimestamp, ap.TimezoneId) AS CreatedDate,
        dbo.fn_GetTimezoneTime(pur.CancellationTimestamp, ap.TimezoneId) AS CancellationDate,
		CASE WHEN psj.StatusId = 4 THEN dbo.fn_GetTimezoneTime(psj.CreatedTimestamp, ap.TimezoneId) ELSE NULL END AS [Date Paid],
        pur.[Description],
        c.Id AS CustomerId,
        c.AccountId,
        i.InvoiceNumber,
		pur.InvoiceOwnerId,
		ist.name  AS PostedInvoiceStatus,
		cur.IsoName as Currency,   
		purst.Name as Status,
		prod.Name AS [Product Name],
		prod.Description as [Product Description],
		pur.Quantity,
		case when pur.IsTrackingItems = 1 then 'Yes' else 'No' end as 'Tracking Unique Quantities',
		prod.Quantity as 'Default Quantity',
		pmt.Name AS [Pricing Model],
		cpn.Name AS Coupons,
		pur.TaxableAmount as NetAmount,
		case when custadrpref.UseBillingAddressAsShippingAddress = 1 then 'Yes' else 'No' end as 'UseCustomerBillingAddress',
		custadrpref.ContactName, 
		ISNULL(custadrpref.ShippingInstructions, '') as [ShippingInstructions],
		case when custadrpref.UseBillingAddressAsShippingAddress = 0 then shipping.Line1 else billing.Line1 end as  [Shipping Line 1],
		case when custadrpref.UseBillingAddressAsShippingAddress = 0 then shipping.Line2 else billing.Line2 end as  [Shipping Line 2],
		case when custadrpref.UseBillingAddressAsShippingAddress = 0 then shipping.City else billing.City end as  [Shipping City],
		case when custadrpref.UseBillingAddressAsShippingAddress = 0 then shipping.Country else billing.Country end as  [Shipping Country],
		case when custadrpref.UseBillingAddressAsShippingAddress = 0 then shipping.State else billing.State end as  [Shipping State],
		case when custadrpref.UseBillingAddressAsShippingAddress = 0 then shipping.PostalZip else billing.PostalZip end as  [Shipping Postal Zip],
		case when custadrpref.UseBillingAddressAsShippingAddress = 0 then shipping.CompanyName else billing.CompanyName end as  [Shipping Company Name],	
		case when custadrpref.UseBillingAddressAsShippingAddress = 0 then shipping.County else billing.County end as  [Shipping County],
		billing.CompanyName AS [Billing Company Name],
		billing.Line1 AS [Billing Line 1],
		billing.Line2 AS [Billing Line 2],
		billing.City AS [Billing City],
		billing.Country AS [Billing Country],
		billing.State AS [BIlling State],
		billing.PostalZip AS [Billing Postal Zip],
		billing.County as [Billing County]
FROM Purchase pur  
INNER join @purchaseIds pids on pids.Id = pur.Id  
INNER join Customer c on c.Id = pur.CustomerId  
INNER JOIN CustomerBillingSetting cbs on cbs.id = c.id
INNER JOIN Lookup.PricingModelType pmt on pmt.Id = pur.PricingModelTypeId
LEFT JOIN Address billing on billing.AddressTypeId = 1 and billing.CustomerAddressPreferenceId = c.id
LEFT JOIN Address shipping on shipping.AddressTypeId = 2 and shipping.CustomerAddressPreferenceId = c.id
INNER JOIN CustomerAddressPreference custadrpref on custadrpref.Id = c.Id
INNER JOIN Lookup.PurchaseStatus purst ON pur.StatusId = purst.Id  
LEFT JOIN Lookup.Currency cur  ON cur.Id = c.CurrencyId  
INNER JOIN AccountPreference ap ON ap.Id = c.AccountId  
INNER JOIN dbo.Product prod ON pur.ProductId = prod.Id
LEFT JOIN dbo.PurchaseCharge pc ON pc.PurchaseId = pur.Id
LEFT JOIN dbo.Charge ch on pc.Id = ch.Id
LEFT JOIN dbo.Invoice i on i.Id = ch.InvoiceId
LEFT JOIN dbo.PaymentSchedule ps ON ps.InvoiceId = i.Id
LEFT JOIN PaymentScheduleJournal psj ON PSJ.PaymentScheduleId = PS.Id AND PSJ.IsActive = 1
LEFT JOIN Lookup.InvoiceStatus ist ON psj.StatusId = ist.Id
LEFT JOIN PurchaseCouponCode pcc on pcc.PurchaseId = pur.Id
LEFT JOIN CouponCode cpc on cpc.Id = pcc.CouponCodeId
LEFT JOIN Coupon cpn on cpn.id = cpc.CouponId
)

Insert Into #PurchaseTempTable  
Select   
	pids.Id,   
	pids.SortOrder, 
	pdata.Name,
	pdata.ProductCode,
	pdata.Description,  
	CASE WHEN pdiscounts.TotalDiscount < 0 THEN GrossAmount ELSE TotalDiscount END as Discounts,   
	pdata.NetAmount,  
	pdata.CreatedDate,  
	pdata.CustomerId,  
	pdata.AccountId,  
	pdata.InvoiceNumber,  
	pdata.Currency,  
	pdata.CancellationDate,  
	pdata.FinalizationDate,  
	pdata.[Date Paid],
	pdata.[status],
	pdata.[PostedInvoiceStatus],
	pdata.InvoiceOwnerId,
	pdata.[Product Name],
	pdata.[Product Description],
	pdata.Quantity,
	pdata.[Tracking Unique Quantities],
	pdata.[Default Quantity],
	pdata.[Pricing Model],
	pdata.Coupons,
	pcharges.[Pending Charges],
	pdata.UseCustomerBillingAddress,
	pdata.ContactName,
	pdata.ShippingInstructions,
	pdata.[Billing Company Name],
	pdata.[Billing Line 1],
	pdata.[Billing Line 2],
	pdata.[Billing City],
	pdata.[Billing Country],
	pdata.[Billing County],
	pdata.[Billing State],
	pdata.[Billing Postal Zip],
	pdata.[Shipping Company Name],
	pdata.[Shipping Line 1],
	pdata.[Shipping Line 2],
	pdata.[Shipping City],
	pdata.[Shipping Country],
	pdata.[Shipping State],
	pdata.[Shipping Postal Zip],
	pdata.[Shipping County]
from @PurchaseIds pids  
	inner join Purchase pur on pur.Id = pids.Id   
	Left join PurchaseDiscounts pdiscounts on pdiscounts.PurchaseId = pids.Id 
	Left join PurchaseCharges pcharges on pcharges.Id = pids.Id 
	inner join PurchaseDetails pdata on pdata.Id = pids.Id  
 
IF @IncludeCustomFields = 1
	BEGIN
		DECLARE @DynamicPivotQuery AS NVARCHAR(MAX)
		DECLARE @PivotColumnNames AS NVARCHAR(MAX)
		DECLARE @ColumnNames AS NVARCHAR(MAX)
		--Get distinct values for the PIVOT Column and field reference
		SELECT	@PivotColumnNames = ISNULL(@PivotColumnNames + ',','') 
					+ QUOTENAME('Purchase CF - ' + FriendlyName )
				,@ColumnNames= ISNULL(@ColumnNames + ',','') 
					+ 'ISNULL([Purchase CF - ' + FriendlyName + '],'''') AS [Purchase CF - ' + FriendlyName + ' ]'
		FROM (
			SELECT DISTINCT TOP 1000 FriendlyName 
			FROM (select AccountId, FriendlyName, PurchaseId, StringValue, DateValue, NumericValue , cfdt.Name as DataType  
			from PurchaseCustomField pcf
			inner join CustomField cf on pcf.CustomFieldId = cf.Id
			inner join Lookup.CustomFieldDataType cfdt on cf.DataTypeId = cfdt.Id
			) p
			WHERE AccountId = @AccountId
			ORDER BY FriendlyName) AS CustomFields  
END

IF @ColumnNames IS NULL
BEGIN
	SET @IncludeCustomFields = 0
END

DECLARE @SQL NVARCHAR(MAX)
DECLARE @CustomFieldQuery  VARCHAR(MAX)
SELECT @SQL = N' '

IF (@IncludeCustomFields = 1)
BEGIN
SELECT @SQL = @SQL + '		  			
			SELECT PurchaseId AS [Purchases With Custom Fields],' + @PivotColumnNames + ' INTO #PurchaseCustomField FROM (	
				SELECT (''Purchase CF - '' + FriendlyName) AS Element
				,ISNULL(CONVERT(VARCHAR(1000), StringValue), '''') AS Value
				,PurchaseId AS PurchaseId 
				FROM (select cf.AccountId, FriendlyName, PurchaseId, StringValue, DateValue, NumericValue , cfdt.Name as DataType  
			from PurchaseCustomField pcf
			inner join #PurchaseTempTable ptt ON ptt.Id = pcf.PurchaseId
			inner join CustomField cf on pcf.CustomFieldId = cf.Id
			inner join Lookup.CustomFieldDataType cfdt on cf.DataTypeId = cfdt.Id
			) p
				WHERE DataType = ''String'' AND AccountId = @AccountId 
			UNION
				SELECT (''Purchase CF - '' + FriendlyName) AS Element
				,ISNULL(CONVERT(VARCHAR(20),DateValue, 120), '''') AS Value
				,PurchaseId AS PurchaseId 
				FROM (select cf.AccountId, FriendlyName, PurchaseId, StringValue, DateValue, NumericValue , cfdt.Name as DataType  
			from PurchaseCustomField pcf
			inner join #PurchaseTempTable ptt ON ptt.Id = pcf.PurchaseId
			inner join CustomField cf on pcf.CustomFieldId = cf.Id
			inner join Lookup.CustomFieldDataType cfdt on cf.DataTypeId = cfdt.Id
			) p
				WHERE DataType = ''DateTime'' AND AccountId = @AccountId 
			UNION
				SELECT (''Purchase CF - '' + FriendlyName) AS Element
					,ISNULL(CONVERT(VARCHAR,NumericValue),'''') AS Value
					,PurchaseId AS PurchaseId 
				FROM (select cf.AccountId, FriendlyName, PurchaseId, StringValue, DateValue, NumericValue , cfdt.Name as DataType  
			from PurchaseCustomField pcf
			inner join #PurchaseTempTable ptt ON ptt.Id = pcf.PurchaseId
			inner join CustomField cf on pcf.CustomFieldId = cf.Id
			inner join Lookup.CustomFieldDataType cfdt on cf.DataTypeId = cfdt.Id
			) p
				WHERE DataType = ''Number'' AND AccountId = @AccountId 
				) x PIVOT (MAX(Value) FOR Element IN (' + @PivotColumnNames + ')) AS t1'
END


SELECT @SQL = @SQL + '
	select cd.*, ptemp.ID as [Purchase ID], ptemp.name as ''Purchase Name'', ptemp.Description as ''Purchase Description'' , ptemp.Quantity, ptemp.[Tracking Unique Quantities], ptemp.[Default Quantity], ptemp.[Product Name] as ''Catalog Product Name'', ptemp.[Product Description] as ''Catalog Product Description'', ptemp.[Purchase Code] as ''Catalog Product Code'', ptemp.[Pricing Model],
	ptemp.Discounts, ptemp.Coupons, ptemp.[Purchase Net Amount], ptemp.Currency, ptemp.[Purchase status], ptemp.[Pending Charges], ptemp.[Purchase Creation Date] as ''Date Created'', ptemp.[Purchase Finalization Date] as ''Date Invoiced'',  
	ptemp.[Purchase Cancellation Timestamp], ptemp.[Invoice Owner CustomerId],ptemp.[Posted Invoice Number], ptemp.[Posted Invoice Status],  ptemp.[Billing Company Name],
	ptemp.[Date Paid],	ptemp.[Billing Line 1], ptemp.[Billing Line 2], ptemp.[Billing City], ptemp.[Billing Country], ptemp.[Billing County], ptemp.[Billing State], ptemp.[Billing Postal Zip], ptemp.[Use Billing Address As Shipping Address],
	ptemp.[Contact Name], ptemp.[Shipping Instructions], ptemp.[Shipping Company Name], ptemp.[Shipping Line 1], ptemp.[Shipping Line 2], ptemp.[Shipping City], ptemp.[Shipping Country], ptemp.[Shipping County], ptemp.[Shipping State],
	ptemp.[Shipping Postal Zip]'
	
	IF (@IncludeCustomFields = 1)
	BEGIN
	
	Select @CustomFieldQuery = CONCAT(@CustomFieldQuery + ',', 'CASE WHEN ' + [Data] + ' IS NULL THEN ''N/A'' ELSE ' + [Data] + ' END AS ' + [Data] + '') from dbo.Split(@pivotColumnNames,',')

		SELECT @SQL = @SQL + ',' + @CustomFieldQuery  
	END	
	
SELECT @SQL = @SQL + ' 
	from #CustomerData cd   
	inner join #PurchaseTempTable ptemp on ptemp.customerid = cd.[Fusebill ID]  
	inner join @PurchaseIds purList on purList.id = ptemp.ID'

	IF (@IncludeCustomFields = 1)
	BEGIN
		SELECT @SQL = @SQL + '
			LEFT Join  #PurchaseCustomField pcf ON pcf.[Purchases With Custom Fields] = ptemp.ID
			' 
	END
	
SELECT @SQL = @SQL + ' 
	WHERE ptemp.AccountId = @AccountId  
	order by purList.SortOrder Asc;
	
	drop table  #CustomerData;  
	Drop Table #PurchaseTempTable;  

	IF OBJECT_ID(''tempdb.dbo.#PurchaseCustomField'', ''U'') IS NOT NULL
	DROP TABLE #PurchaseCustomField; 
	'
EXEC sp_executesql @SQL ,N'@purchaseIds AS [dbo].[IdListSorted] ReadOnly, @AccountId BIGINT, @IncludeCustomFields bit'
						,@purchaseIds,@AccountId,@IncludeCustomFields

END

GO

