CREATE FUNCTION [dbo].[BasicCustomerDataByAccount]
(	
	@AccountId as bigint
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
		,isnull(c.PrimaryEmail,'') as [Customer Primary Email]
		,c.ParentId as [Customer Parent ID] -- standard stops here\,
		,ISNULL(clh.Name,'') AS [Collection Likelihood]
		,ISNULL(cs.Name, '') as [Current Customer Status]
		,ISNULL(cas.Name, '') as [Current Customer Accounting Status]
	FROM Customer c
	LEFT JOIN lookup.CollectionLikelihood clh	ON clh.Id = c.CollectionLikelihood
	left join Lookup.CustomerStatus cs on cs.Id = c.StatusId
	left join Lookup.CustomerAccountStatus cas on cas.Id = c.AccountStatusId
	WHERE c.AccountId = @AccountId
)

GO

