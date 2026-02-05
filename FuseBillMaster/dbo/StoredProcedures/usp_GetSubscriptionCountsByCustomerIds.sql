
CREATE PROCEDURE [dbo].[usp_GetSubscriptionCountsByCustomerIds]
	@accountId BIGINT,
	@customerIds AS dbo.IDList READONLY

AS
BEGIN

	SELECT	c.Id as CustomerId,
			s.StatusId,
			COUNT(*) as SubscriptionCount
	FROM Subscription s
	INNER JOIN @customerIds cid ON cid.Id = s.CustomerId
	INNER JOIN Customer c ON c.Id = s.CustomerId
	WHERE c.AccountId = @accountid

	/*
		Draft = 1
		Active = 2
		Provisioning = 4
		Suspended = 6
	*/
	AND s.StatusId IN (1,2,4,6)
	And s.IsDeleted = 0
	GROUP BY c.Id, s.StatusId
END

GO

