CREATE PROCEDURE [dbo].[usp_GetCustomerCredentialEmailExport]
 @accountId BIGINT
AS  
BEGIN  
	 -- SET NOCOUNT ON added to prevent extra result sets from  
	 -- interfering with SELECT statements.  
	SET NOCOUNT ON;  

	SELECT 
		c.Id AS [StaxBillId]  
		, c.Reference AS [Customer Reference]
		, c.FirstName AS [Customer First Name]  
		, c.LastName AS [Customer Last Name]  
		, c.CompanyName AS [Customer Company Name]  
		, c.PrimaryEmail AS [Customer Email]
		, cc.Username as [Customer SSP User Name]
		, c.EffectiveTimestamp as [Customer Created Date]
		, cs.Name as [Customer Status]
	FROM Customer c
	INNER JOIN Lookup.CustomerStatus cs ON cs.Id = c.StatusId
	LEFT JOIN CustomerCredential cc ON c.Id = cc.Id
	WHERE (cc.Id IS NULL OR cc.Password IS NULL OR LEN(cc.Password) = 0)
		AND c.AccountId = @accountId

END

GO

