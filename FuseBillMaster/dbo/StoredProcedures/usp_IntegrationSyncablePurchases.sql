CREATE PROCEDURE [dbo].[usp_IntegrationSyncablePurchases]
	@isNetsuiteSync BIT, 
	@accountdId BIGINT,
	@customerId BIGINT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
		p.Id,
		p.SalesforceId,
		CONVERT(VARCHAR, NULL) as 'NetsuiteId' -- this matches the partial purchase model where we "hack" in a netsuite id as null anyways.
	FROM
		Purchase p
		INNER JOIN Customer c ON c.Id = p.CustomerId
	WHERE
		c.AccountId = @accountdId
		AND (c.SalesforceSynchStatusId = 1 OR @isNetsuiteSync = 1)
		AND (c.Id = ISNULL(@customerId, c.Id))
	ORDER BY c.Id ASC
END

GO

