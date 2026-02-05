
CREATE FUNCTION [dbo].[SubscriptionProductBasicCollection]
(	
		@AccountId bigint
	   , @EndDate datetime
)
RETURNS @SubProductBasicCollection TABLE 
(
[Subscription Product ID] bigint,
[Subscription Product Include Status] VARCHAR(50),
[Subscription Product Status] VARCHAR(50)
)

AS
BEGIN 

--declare        @AccountId bigint 
--       , @StartDate datetime 
--       , @EndDate datetime 
--       , @IncludeFullCustomerDetails bit
--       , @PlanFrequencyUniqueId bigint = null
--       , @PlanId bigint = null
--       , @CurrencyId int = null
--       , @SalesTrackingCode1IdList nvarchar(2000) = ''
--       , @SalesTrackingCode2IdList nvarchar(2000) = '' 
--       , @SalesTrackingCode3IdList nvarchar(2000) = ''
--       , @SalesTrackingCode4IdList nvarchar(2000) = '' 
--       , @SalesTrackingCode5IdList nvarchar(2000) = '' 
--	   , @IncludeCustomFields bit
--	   , @SubscriptionId bigint


--	SET @AccountId=21;
--	SET @SubscriptionId=12525;
--	SET @StartDate='1900-01-01 00:00:00';
--	SET @EndDate='2018-01-01';
--	SET @IncludeFullCustomerDetails=0;
--	SET @IncludeCustomFields=1;
--	SET @PlanFrequencyUniqueId=NULL;
--	SET @PlanId=null;
--	SET @CurrencyId=NULL;

declare @TimezoneId int

select @TimezoneId = TimezoneId
from AccountPreference where Id = @AccountId ;

WITH MostRecentJournal AS (
       SELECT MAX(j.Id) as Id, SubscriptionProductId
       FROM SubscriptionProductJournal j
       inner join subscriptionproduct sp
       on j.subscriptionproductid = sp.Id 
       inner join Product p on sp.productid = p.Id and p.AccountId = @AccountId
       WHERE j.CreatedTimestamp <= @EndDate
       GROUP BY SubscriptionProductId),
	LatestBillingPeriod as
	(
		SELECT Max(bp.Id) as Id, s.Id as SubscriptionId  
		FROM BillingPeriod bp
		INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = bp.BillingPeriodDefinitionId
		INNER JOIN Subscription s ON bpd.Id = s.BillingPeriodDefinitionId
		WHERE bp.PeriodStatusId = 1 
		GROUP BY s.Id
	)

	Insert @SubProductBasicCollection ([Subscription Product ID], [Subscription Product Include Status], [Subscription Product Status]  )
	SELECT 		sp.Id as [Subscription Product ID],
		spj.SubscriptionProductIncludedStatus as [Subscription Product Included Status],
		Lookup.ProductStatus.Name as [Subscription Product Status]
	
    FROM Product p
              INNER JOIN SubscriptionProduct sp ON p.Id = sp.ProductId
              LEFT JOIN SubscriptionProductOverride spo ON spo.Id = sp.Id
              INNER JOIN MostRecentJournal mrj ON sp.Id = mrj.SubscriptionProductId 
              INNER JOIN SubscriptionProductJournal spj ON spj.Id = mrj.Id
			  LEFT Join Lookup.ProductStatus on Lookup.ProductStatus.Id = spj.SubscriptionProductStatusId
			  

 RETURN     
END

GO

