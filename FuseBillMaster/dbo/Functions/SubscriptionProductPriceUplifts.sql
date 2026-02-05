
CREATE FUNCTION [dbo].[SubscriptionProductPriceUplifts]
(	
		    @SubscriptionProductId bigint
			, @SubscriptionNextRechargeTimestamp datetime	
			, @IntervalId int 
			, @SubscriptionNumberOfIntervals int
			, @TimezoneId int
)
RETURNS @SubProductPriceUplift TABLE 
(
[Price Uplift Exists] bit,
[# of Periods Until Next Uplift] int,
[Next Uplift Date] datetime,
[Uplift Price Increase Percentage] Decimal(18,6),
[Uplift Price From] money,
[Uplift Price To] money,
[Uplift Prior To Recharge] bit,
[Uplift Repeat Forever] bit
)

AS
BEGIN 

--declare        @SubscriptionProductId bigint
--			, @SubscriptionNextRechargeTimestamp datetime	
--			, @IntervalId int 
--			, @SubscriptionNumberOfIntervals int
--			, @TimezoneId int
--SET @SubscriptionProductId=17041; -- 17038, 17041
--SET @SubscriptionNextRechargeTimestamp='2017-06-02'; -- '2017-06-02'
--SET @IntervalId = 3;
--SET @SubscriptionNumberOfIntervals = 1;
--SET @TimezoneId = 335;



Insert @SubProductPriceUplift ([Price Uplift Exists], [# of Periods Until Next Uplift], [Next Uplift Date], [Uplift Price Increase Percentage],[Uplift Price From],[Uplift Price To],[Uplift Prior To Recharge],[Uplift Repeat Forever])
select 1 as [Exists]
	,sppu.[RemainingIntervals]
	, COALESCE(CONVERT(varchar(20),convert(datetime,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone([dbo].[fn_CalculateExpiringDate](@SubscriptionNextRechargeTimestamp, @SubscriptionNumberOfIntervals, @IntervalId ,sppu.[RemainingIntervals] - 1),@TimezoneId )), 120), '') as NextUpliftDate
      ,sppu.[Amount] as PercentIncrease
	  ,sp.Amount as PriceFrom
	  ,(sp.Amount + (sp.Amount * sppu.Amount / 100)) as PriceTo
      ,sppu.[UpliftPriorToRecharge]
      ,sppu.[RepeatForever]
from [dbo].[SubscriptionProduct] as sp
	Left Join [dbo].[SubscriptionProductPriceUplift] as sppu on sppu.SubscriptionProductId = sp.Id
where sp.Id = @SubscriptionProductId and 
		sppu.IsCurrent = 1
		and sp.PriceUpliftsEnabled = 1
union
select 0 as [Exists], null as [RemainingIntervals] ,null as NextUpliftDate, null as [PercentIncrease] , null as PriceFrom, null as PriceTo, null as [UpliftPriorToRecharge], null as [RepeatForever]   
from [dbo].[SubscriptionProductPriceUplift] 
where not exists( select 1 as [Exists]
	,sppu.[RemainingIntervals]
	, COALESCE(CONVERT(varchar(20),convert(datetime,dbo.fn_ConvertDateTimeToSmallDateTimeWithTimezone([dbo].[fn_CalculateExpiringDate](@SubscriptionNextRechargeTimestamp, @SubscriptionNumberOfIntervals, @IntervalId ,[RemainingIntervals] - 1),@TimezoneId )), 120), '') as NextUpliftDate
      ,sppu.[Amount] as PercentIncrease
	  ,sp.Amount as PriceFrom
	  ,(sp.Amount + (sp.Amount * sppu.Amount / 100)) as PriceTo
      ,sppu.[UpliftPriorToRecharge]
      ,sppu.[RepeatForever]
    from [dbo].[SubscriptionProduct] as sp
	Left Join [dbo].[SubscriptionProductPriceUplift] as sppu on sppu.SubscriptionProductId = sp.Id
where sp.Id = @SubscriptionProductId and 
		sppu.IsCurrent = 1
		and sp.PriceUpliftsEnabled = 1 )

			  

 RETURN     
END

GO

