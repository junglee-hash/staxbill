

CREATE PROCEDURE [dbo].[usp_GetRemainingReverseAmount]
	-- Add the parameters for the stored procedure here
	@SubscriptionId bigint, 
	@ReversalType nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	if @ReversalType = 'Full'
		begin
			select 
				sum(c.RemainingReverseAmount) as 'Remaining Reverse Amount'
			from SubscriptionProductCharge spc
			join SubscriptionProduct sp on sp.id = spc.SubscriptionProductId
			join BillingPeriod bp on bp.Id = spc.BillingPeriodId
			join Charge c on c.id = spc.Id
			where 
				sp.SubscriptionId = @SubscriptionId
				and bp.PeriodStatusId = 1
		end

	if @ReversalType = 'Unearned'
		begin
			select 
				sum(c.RemainingReverseAmount) as 'Remaining Reverse Amount'
			from SubscriptionProductCharge spc
			join SubscriptionProduct sp on sp.id = spc.SubscriptionProductId
			join BillingPeriod bp on bp.Id = spc.BillingPeriodId
			join Charge c on c.id = spc.Id
			where 
				sp.SubscriptionId = @SubscriptionId
				and bp.PeriodStatusId in (1,2)
		end
END

GO

