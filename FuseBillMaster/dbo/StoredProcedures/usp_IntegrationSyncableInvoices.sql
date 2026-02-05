CREATE   PROCEDURE [dbo].[usp_IntegrationSyncableInvoices]
	@isNetsuiteSync BIT, 
	@accountdId BIGINT,
	@customerId BIGINT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT 
		i.Id,
		i.SalesforceId,
		i.NetsuiteId
	FROM
		Invoice i
		INNER JOIN Customer c ON c.Id = i.CustomerId
	WHERE
		c.AccountId = @accountdId
		AND i.AccountId = @accountdId
		AND (c.SalesforceSynchStatusId = 1 OR @isNetsuiteSync = 1)
		AND (c.Id = ISNULL(@customerId, c.Id))
	ORDER BY c.Id ASC
END

GO

