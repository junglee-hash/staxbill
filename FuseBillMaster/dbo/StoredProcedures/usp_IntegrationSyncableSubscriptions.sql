CREATE PROCEDURE [dbo].[usp_IntegrationSyncableSubscriptions]
	@isNetsuiteSync BIT, 
	@accountdId BIGINT,
	@customerId BIGINT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
		s.Id,
		s.SalesforceId,
		s.NetsuiteId
	FROM
		Subscription s
		INNER JOIN Customer c ON c.Id = s.CustomerId
	WHERE
		c.AccountId = @accountdId
		AND (c.SalesforceSynchStatusId = 1 OR @isNetsuiteSync = 1)
		AND (c.Id = ISNULL(@customerId, c.Id))
	ORDER BY c.Id ASC
END

GO

