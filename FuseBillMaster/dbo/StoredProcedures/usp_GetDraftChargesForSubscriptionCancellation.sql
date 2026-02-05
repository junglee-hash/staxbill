
CREATE PROCEDURE [dbo].[usp_GetDraftChargesForSubscriptionCancellation]
 @draftChargeIds AS dbo.IDList READONLY,    
 @accountId bigint    
AS    
 -- SET NOCOUNT ON added to prevent extra result sets from    
 -- interfering with SELECT statements.    
SET NOCOUNT ON;    
    
SELECT    
  dd.DiscountTypeId as DiscountType    
 , dd.TransactionTypeId as TransactionType 
 ,*
FROM [dbo].[DraftDiscount] dd    
INNER JOIN @draftChargeIds dc ON dd.DraftChargeId = dc.Id    
    
SELECT dt.Id    
 , dt.TaxRuleId    
 , dt.DraftInvoiceId    
 , dt.DraftChargeId    
 , dt.Amount    
 , dt.CurrencyId    
FROM [dbo].[DraftTax] dt    
INNER JOIN @draftChargeIds dc ON dt.DraftChargeId = dc.Id    
    
SELECT dcpi.*    
FROM [dbo].[DraftChargeProductItem] dcpi    
INNER JOIN @draftChargeIds dc ON dcpi.DraftChargeId = dc.Id    
    
SELECT DISTINCT ds.*    
FROM [dbo].[DraftPaymentSchedule] ds    
INNER JOIN DraftCharge dc on dc.DraftInvoiceId = ds.DraftInvoiceId    
INNER JOIN @draftChargeIds di ON dc.Id = di.Id    
  
SELECT DISTINCT celdi.Id, celdi.CustomerEmailLogId, celdi.DraftInvoiceId  
FROM draftinvoice di   
JOIN DraftCharge dc ON di.id = dc.DraftInvoiceId  
JOIN CustomerEmailLogDraftInvoice celdi ON celdi.DraftInvoiceId = di.Id  
JOIN @draftChargeIds dci ON dci.Id = dc.id

SELECT DISTINCT d.*    
 , DraftInvoiceStatusId as DraftInvoiceStatus    
FROM [dbo].[DraftInvoice] d    
INNER JOIN DraftCharge dc on dc.DraftInvoiceId = d.Id    
INNER JOIN @draftChargeIds di ON dc.Id = di.Id

GO

