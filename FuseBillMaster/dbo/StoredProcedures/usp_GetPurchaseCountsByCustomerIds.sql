CREATE PROCEDURE [dbo].[usp_GetPurchaseCountsByCustomerIds]
	@accountId BIGINT,
	@customerIds AS dbo.IDList READONLY

AS
BEGIN
	SELECT	c.Id AS CustomerId,
			COUNT(*) AS PurchaseCount
	FROM
	(
		SELECT	Id
		FROM [dbo].[Customer]
		WHERE AccountId = @accountId
	) AS c
	JOIN [dbo].[Purchase] p
		ON p.CustomerId = c.Id
	INNER JOIN @customerIds cid
		ON cid.Id = c.Id

	--Draft = 1
	WHERE p.StatusId = 1
	and p.IsDeleted = 0
	GROUP BY c.Id
END

GO

