

Create PROCEDURE [Reporting].[Inyo_QuickbooksInvoice]
	@AccountId BIGINT 
	,@StartDate DATETIME 
	,@EndDate DATETIME
	
AS
BEGIN


set nocount on;
set transaction isolation level snapshot;

declare @Timezone int

select 
	@StartDate = dbo.fn_GetUtcTime (@StartDate,TimezoneId)
	,@EndDate = dbo.fn_GetUtcTime (@EndDate,TimezoneId)
	,@Timezone = TimezoneId
from 
	AccountPreference 
where 
	Id = @AccountId;

DECLARE @ProductMap TABLE
(
	SourceName NVARCHAR(2000)
	,TargetName NVARCHAR(255)
)
INSERT INTO @ProductMap (SourceName,TargetName) VALUES ('Video Surcharges','Surcharges - Inyo')
INSERT INTO @ProductMap (SourceName,TargetName) VALUES ('PEG Channel Fee','Surcharges - Inyo')
INSERT INTO @ProductMap (SourceName,TargetName) VALUES ('PUC Instrastate Fee','Surcharges - Inyo')



;WITH Discounts AS (
	SELECT
		d.ChargeId
		,SUM(dt.Amount) as Amount
	FROM Discount d
	INNER JOIN [Transaction] dt ON d.Id = dt.Id
	WHERE dt.AccountId = @AccountId
		AND dt.TransactionTypeId IN (14,21)
		AND dt.EffectiveTimestamp >= @StartDate
		AND dt.EffectiveTimestamp < @EndDate
	GROUP BY d.ChargeId
)
SELECT
	c.Id as [Fusebill Id]
	,ISNULL(c.FirstName,'') + ' ' + ISNULL(c.LastName,'') as [Customer Name]
	,ISNULL(a.Line1,'') + ' ' + ISNULL(a.Line2,'') + ',' + ISNULL(a.City,'') + ',' + ISNULL(a.State,'') + ',' + ISNULL(a.PostalZip,'') as Address
	,i.InvoiceNumber as [Invoice Number]
	,dbo.fn_GetTimezoneTime(i.PostedTimestamp,@Timezone) as [Invoice Date]
	,ISNULL(c.Reference,'') as [Account Number]
	,ISNULL(sp.Description,'') as [Service Id]
	--For recurring charges, Product is the text after the hyphen on the invoice
	--For purchases, Product is either Surcharges - Inyo or Taxes & Surcharges and that is based on the charge name
	,CASE WHEN pu.Id IS NOT NULL THEN 
		ISNULL(pm.TargetName,'Taxes & Surcharges') 
	ELSE 
		CASE WHEN CHARINDEX('-',ch.Name) > 0 THEN 
			LTRIM(RIGHT(ch.Name,LEN(ch.Name)-CHARINDEX('-',ch.Name))) 
		ELSE	
			ch.Name
		END
	END as Product
	--For recurring chages, Component is the text before the hyphen on the invoice
	--For purchases, Component is the text on the invoice
	,CASE WHEN pu.Id IS NOT NULL THEN 
		ch.Name 
	ELSE 
		CASE WHEN CHARINDEX('-',ch.Name) > 0 THEN
			RTRIM(LTRIM(LEFT(ch.Name,CHARINDEX('-',ch.Name) - 1))) 
		ELSE	
			ch.Name
		END
	END as Component
	--No service dates for purchases
	,ISNULL(CONVERT(varchar,CONVERT(DATE,spc.StartServiceDateLabel)),'') as [From Date]
	,ISNULL(CONVERT(varchar,CONVERT(DATE,spc.EndServiceDateLabel)),'') as [To Date]
	,ch.Quantity
	,COALESCE(ch.ProratedUnitPrice,ch.UnitPrice) as Rate
	,t.Amount
	,ISNULL(d.Amount,0) as [Discount Amount]
	,t.Amount - ISNULL(d.Amount,0) as [Net Amount]
FROM Charge ch
LEFT JOIN SubscriptionProductCharge spc ON ch.Id = spc.Id
LEFT JOIN PurchaseCharge pc ON pc.Id = ch.Id
INNER JOIN [Transaction] t ON t.Id = ch.Id
INNER JOIN Customer c ON c.Id = t.CustomerId
LEFT JOIN [Address] a ON c.Id = a.CustomerAddressPreferenceId AND a.AddressTypeId = 1 --Billing
INNER JOIN Invoice i ON i.Id = ch.InvoiceId
LEFT JOIN SubscriptionProductOverride sp ON sp.Id = spc.SubscriptionProductId
LEFT JOIN Purchase pu ON pu.Id = pc.PurchaseId
LEFT JOIN GLCode gl ON gl.Id = ch.GLCodeId
LEFT JOIN Discounts d ON ch.Id = d.ChargeId
LEFT JOIN @ProductMap pm ON pm.SourceName = ch.Name
WHERE t.AccountId = @AccountId	
	AND i.PostedTimestamp >= @StartDate
	AND i.PostedTimestamp < @EndDate
END

GO

