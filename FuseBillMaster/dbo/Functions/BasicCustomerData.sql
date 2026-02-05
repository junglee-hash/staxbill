
CREATE FUNCTION [dbo].[BasicCustomerData]
(	
	@FusebillId as bigint
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
		,c.ParentId as [Customer Parent ID] -- standard stops here\
	FROM Customer c
	WHERE c.Id = @FusebillId
)

GO

