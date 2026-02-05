CREATE PROCEDURE [dbo].[usp_IntegrationSyncableCustomers]
	@isNetsuiteSync BIT, 
	@accountdId BIGINT,
	@customerId BIGINT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


    SELECT 
		c.Id,
		c.SalesforceId,
		c.NetsuiteId
	FROM
		Customer c
	WHERE
		c.AccountId = @accountdId
		AND (c.SalesforceSynchStatusId = 1 OR @isNetsuiteSync = 1)
		AND (c.Id = ISNULL(@customerId, c.Id))
	ORDER BY c.Id ASC

END

GO

