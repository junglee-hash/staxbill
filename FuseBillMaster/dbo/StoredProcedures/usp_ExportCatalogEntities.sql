
CREATE PROCEDURE dbo.usp_ExportCatalogEntities
	@AccountId BIGINT
AS
BEGIN

	SET NOCOUNT ON;

with t1 as (
SELECT [AccountId]
	  ,'currency' as [Type]
	  ,ac.CurrencyId as [EntityId]
	  ,lc.isoName as [Code]
	  ,lc.isoName as [Name]
	  ,CASE when CurrencyStatusId = 1 then 'Draft' when CurrencyStatusId= 2 then 'Active' when CurrencyStatusId= 3 then 'Retired' END  AS [Status]
FROM dbo.AccountCurrency as ac
JOIN Lookup.Currency AS lc ON ac.CurrencyId = lc.Id
WHERE AccountId = @AccountId

UNION ALL

SELECT [AccountId] 
	  ,'customfields' as [Type]
      ,[Id]
      ,[Key] AS[Code]
      ,[FriendlyName] AS[Name]
	  ,CASE when[StatusId] = 1 then 'Active' when [StatusId]= 2 then 'Retired' END  AS [Status]
FROM dbo.[CustomField]
WHERE AccountId = @AccountId

UNION ALL

SELECT [AccountId] 
	  ,'glcode' as [Type]
	  ,Id as [EntityId]
	  ,[Code]
	  ,[Name]
	  ,CASE when[StatusId] = 1 then 'Active' when [StatusId]= 2 then 'Retired' END  AS [Status]
FROM dbo.[GLCode]
WHERE AccountId = @AccountId

UNION ALL

SELECT c.AccountId
	  ,'coupon' as [Type]
	  ,c.Id as [EntityId]
	  ,cc.Code
	  ,c.Name
	  ,CASE when[StatusId] = 1 then 'Draft' when [StatusId]= 2 then 'Active' when [StatusId]= 3 then 'Expired' when [StatusId]= 4 then 'Retired' when [StatusId]= 5 then 'Consumed' when [StatusId]= 6 then 'Ineligible' END  AS [Status]
FROM dbo.Coupon AS c
JOIN dbo.CouponCode AS cc ON c.Id = cc.CouponId
WHERE c.AccountId = @AccountId

UNION ALL

SELECT [AccountId]
	  ,'discount' as [Type]
      ,[Id] as [EntityId]
      ,[Code]
      ,[Name]
	  ,CASE when[StatusId] = 1 then 'Active' when [StatusId]= 2 then 'Retired' END  AS [Status]
FROM dbo.[DiscountConfiguration]
WHERE AccountId = @AccountId

UNION ALL

SELECT [AccountId]
	  ,'plan' as [Type]
      ,[Id] as [EntityId]
      ,[Code]
      ,[Name]
	  ,CASE when[StatusId] = 1 then 'Active' when [StatusId]= 2 then 'Retired' END  AS [Status]
FROM dbo.[Plan]
WHERE AccountId = @AccountId

UNION ALL

SELECT [AccountId]
	  ,'product' as [Type]
      ,[Id]
      ,[Code]
      ,[Name]
	  ,CASE when[ProductStatusId] = 1 then 'Active' when [ProductStatusId]= 2 then 'Retired' END  AS [Status]
FROM dbo.[Product]
WHERE AccountId = @AccountId
AND Code != 'plansetupfee' 
AND Code != 'plancharge'

UNION ALL

SELECT [AccountId]
	  ,'planfamily' as [Type]
      ,[Id]
      ,[Code]
      ,[Name]
	  ,'Active' AS[Status]
FROM dbo.[PlanFamily]
WHERE AccountId = @AccountId
)
select* from t1
ORDER BY CASE WHEN [Type] = 'currency' then 0 else 1 END,
Type, Code

END

GO

