
CREATE Function [dbo].[fn_getSubscriptionProductMRR]
(
@SubscriptionProductId bigint 
)
Returns Money
as
BEGIN

declare @Result money
select @Result = (
select sum(Mrr) from vw_MonthlyRecurringRevenue
where SubscriptionProductId = @SubscriptionProductId )

select @Result = isnull(@Result,0)
Return @Result 
END

GO

