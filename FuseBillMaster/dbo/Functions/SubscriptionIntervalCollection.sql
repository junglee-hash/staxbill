CREATE FUNCTION [dbo].[SubscriptionIntervalCollection]
(	
	@AccountId as bigint
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT s.id as XXXSubscriptionId, it.Name as Interval,
			s.NumberOfIntervals as [Number Of Intervals]
    FROM Subscription s
		INNER JOIN Customer c on c.Id = s.CustomerId and c.AccountId = @AccountId
			  left join Lookup.Interval it on s.IntervalId = it.Id 
	
)

GO

