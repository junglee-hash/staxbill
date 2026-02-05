

CREATE Function [dbo].[fn_getSubscriptionProductAmount]
(
@SubscriptionProductId bigint 
)
Returns Money
as
BEGIN

declare @Result money
select @Result = (
select sum(Amount) from vw_SubscriptionAmount 
where SubscriptionProductId = @SubscriptionProductId )

select @Result = isnull(@Result,0)
Return @Result 
END

GO

