CREATE FUNCTION [dbo].[SubscriptionPlanBasicCollection]
(	
		@AccountId bigint
       , @PlanFrequencyUniqueId bigint = null
       , @PlanId bigint = null
       , @CurrencyId int = null
       , @SalesTrackingCode1IdList nvarchar(2000) = null
       , @SalesTrackingCode2IdList nvarchar(2000) = null 
       , @SalesTrackingCode3IdList nvarchar(2000) = null
       , @SalesTrackingCode4IdList nvarchar(2000) = null 
       , @SalesTrackingCode5IdList nvarchar(2000) = null
	   , @EndDate datetime
	   , @SubscriptionId bigint = null
)
RETURNS @SubBasicCollection TABLE 
(
CustomerId bigint,
CustCreateTs datetime,
[Plan Name] NVARCHAR(100),
[Plan Description] NVARCHAR(1000),
[Plan Code] NVARCHAR(255),
[Plan Reference] NVARCHAR(255),
[Plan Family] NVARCHAR(100),
[Subscription Id] bigint
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

	WITH 
	MostRecentJournal AS (
       SELECT MAX(j.Id) as Id, SubscriptionId
       FROM SubscriptionStatusJournal j
       WHERE j.CreatedTimestamp <= @EndDate
       GROUP BY SubscriptionId),

	MostRecentCustomerStatusJournal AS (SELECT MAX(j.Id) as Id, CustomerId
       FROM CustomerStatusJournal j
       WHERE j.CreatedTimestamp <= @EndDate
       GROUP BY CustomerId),

	MostRecentCustomerAccountStatusJournal AS (SELECT MAX(j.Id) as Id, CustomerId
       FROM CustomerAccountStatusJournal j
       WHERE j.EffectiveTimestamp <= @EndDate
       GROUP BY CustomerId)

	Insert @SubBasicCollection (CustomerId, CustCreateTs, [Plan Name],[Plan Description],[Plan Code],[Plan Reference] ,[Plan Family], [Subscription Id] )
	SELECT s.CustomerId, c.CreatedTimestamp,  s.PlanName as [Plan Name],
			 COALESCE(s.PlanDescription, '') as [Plan Description],
			s.PlanCode as [Plan Code],
			COALESCE(s.PlanReference, '') as [Plan Reference],
			COALESCE(pf.Name, '') as [Plan Family],
			s.Id	
    FROM Subscription s
			INNER JOIN Customer c on c.Id = s.CustomerId and c.AccountId = @AccountId
			INNER JOIN CustomerReference cr on cr.Id = c.Id
              INNER JOIN MostRecentJournal mrj ON s.Id = mrj.SubscriptionId 
              INNER JOIN SubscriptionStatusJournal ssj ON ssj.Id = mrj.Id
			  INNER JOIN MostRecentCustomerStatusJournal mcsj ON mcsj.CustomerId = c.Id
			  INNER JOIN CustomerStatusJournal csj ON csj.Id = mcsj.Id
			  INNER JOIN MostRecentCustomerAccountStatusJournal mcasj ON mcasj.CustomerId = c.Id
			  INNER JOIN CustomerAccountStatusJournal casj ON casj.Id = mcasj.Id
			  INNER JOIN BillingPeriodDefinition bpd ON bpd.Id = s.BillingPeriodDefinitionId
			  INNER JOIN BillingPeriod bp ON bpd.Id = bp.BillingPeriodDefinitionId AND bp.PeriodStatusId = 1
			  INNER JOIN AccountFeatureConfiguration afc ON afc.Id = c.AccountId		  
			  AND ((ISNULL(@SalesTrackingCode1IdList, 'N') != 'N' AND @SalesTrackingCode1IdList != '' AND cr.SalesTrackingCode1Id in (select Data from dbo.Split (@SalesTrackingCode1IdList,',') ))
			  OR (ISNULL(@SalesTrackingCode1IdList, 'N') = 'N' AND cr.SalesTrackingCode1Id is null) or (@SalesTrackingCode1IdList = ''))
			  AND ((ISNULL(@SalesTrackingCode2IdList, 'N') != 'N' AND @SalesTrackingCode2IdList != ''  AND cr.SalesTrackingCode2Id in (select Data from dbo.Split (@SalesTrackingCode2IdList,',') ))
			  OR (ISNULL(@SalesTrackingCode2IdList, 'N') = 'N' AND cr.SalesTrackingCode2Id is null) or (@SalesTrackingCode2IdList = ''))
			  AND ((ISNULL(@SalesTrackingCode3IdList, 'N') != 'N' AND @SalesTrackingCode3IdList != ''  AND cr.SalesTrackingCode3Id in (select Data from dbo.Split (@SalesTrackingCode3IdList,',') ))
			  OR (ISNULL(@SalesTrackingCode3IdList, 'N') = 'N' AND cr.SalesTrackingCode3Id is null) or (@SalesTrackingCode3IdList = ''))
			  AND ((ISNULL(@SalesTrackingCode4IdList, 'N') != 'N' AND @SalesTrackingCode4IdList != ''  AND cr.SalesTrackingCode4Id in (select Data from dbo.Split (@SalesTrackingCode4IdList,',') ))
			  OR (ISNULL(@SalesTrackingCode4IdList, 'N') = 'N' AND cr.SalesTrackingCode4Id is null) or (@SalesTrackingCode4IdList = '' ))
			  AND ((ISNULL(@SalesTrackingCode5IdList, 'N') != 'N' AND @SalesTrackingCode5IdList != ''  AND cr.SalesTrackingCode5Id in (select Data from dbo.Split (@SalesTrackingCode5IdList,',') ))
			  OR (ISNULL(@SalesTrackingCode5IdList, 'N') = 'N' AND cr.SalesTrackingCode5Id is null) or (@SalesTrackingCode5IdList = '' ))
			  AND ((@PlanId IS NOT NULL AND s.PlanId = @PlanId) or (@PlanId IS NULL ))
			  AND ((@PlanFrequencyUniqueId IS NOT NULL and s.PlanFrequencyId = @PlanFrequencyUniqueId) or (@PlanFrequencyUniqueId IS NULL))
 			  AND ((@CurrencyId IS NOT NULL and c.CurrencyId =  convert(varchar(2),@CurrencyId)) or (@CurrencyId IS NULL ))
              left join SalesTrackingCode stc1 on cr.SalesTrackingCode1Id = stc1.Id
              left join SalesTrackingCode stc2 on cr.SalesTrackingCode2Id = stc2.Id
              left join SalesTrackingCode stc3 on cr.SalesTrackingCode3Id = stc3.Id
              left join SalesTrackingCode stc4 on cr.SalesTrackingCode4Id = stc4.Id
              left join SalesTrackingCode stc5 on cr.SalesTrackingCode5Id = stc5.Id

			  LEFT JOIN PlanFamilyPlan pfp on pfp.PlanId = s.PlanId
			  LEFT JOIN PlanFamily pf ON pf.Id = pfp.PlanFamilyId
			  WHERE s.Id =  COALESCE(@SubscriptionId,s.Id)   
			  

 RETURN     
END

GO

