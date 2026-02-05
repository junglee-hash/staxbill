
CREATE PROCEDURE [dbo].[usp_AreSubscriptionsDraft]
	@subscriptionProductIds AS dbo.IDList READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select Count(sub.Id) from SubscriptionProduct sp
	inner join @subscriptionProductIds spIds on sp.Id = spIds.id
	inner join Subscription sub on sub.Id = sp.SubscriptionId and sub.StatusId = 1


END

GO

