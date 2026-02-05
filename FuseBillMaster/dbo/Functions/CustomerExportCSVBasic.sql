CREATE FUNCTION [dbo].[CustomerExportCSVBasic]
(	
	@AccountId as bigint,
	@CustomerId as bigint
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT
		c.Id as [Fusebill ID]
		,isnull(c.Reference,'') as [Customer ID]
		,isnull(c.FirstName,'') as  [Customer First Name]
		,isnull(c.LastName,'') as [Customer Last Name]
		,isnull(c.CompanyName,'') as [Customer Company Name]
		,customerStatus.Name as [Current Status]
		,isnull(CONVERT(varchar,c.ParentId), '') as [Customer Parent ID] 
		,CASE WHEN str(c.QuickBooksId) is null THEN '' ELSE str(c.QuickBooksId) END as [QuickBooks ID]
		,ISNULL(qblt.Name, '') as [QuickBooks Latch Type]
		,ISNULL(c.SalesforceId, '') as [Salesforce Id]
		,ISNULL(sfat.Name, '') as [Salesforce Account Type]
		,ISNULL(sfss.Name, '') as [Salesforce Synch Status]
		,ISNULL(c.NetsuiteId, '') as [Netsuite Id] -- standard stops here\
		,ISNULL(sfss.Name, '') as [Netsuite Synch Status]
	FROM Customer c
	INNER JOIN Lookup.CustomerStatus customerStatus ON c.StatusId = customerStatus.Id 
	LEFT JOIN Lookup.QuickBooksLatchType qblt on qblt.Id = c.QuickBooksLatchTypeId
	LEFT JOIN Lookup.SalesforceAccountType sfat on sfat.Id = c.SalesforceAccountTypeId
	LEFT JOIN Lookup.SalesforceSynchStatus sfss on sfss.Id = c.SalesforceSynchStatusId
	LEFT JOIN Lookup.SalesforceSynchStatus nsss on nsss.Id = c.NetsuiteSynchStatusId
	WHERE ((ISNULL(@AccountId, 0) = 0 AND c.Id = @CustomerId)
	OR (ISNULL(@AccountId, 0) != 0 AND c.AccountId = @AccountId))
)

GO

