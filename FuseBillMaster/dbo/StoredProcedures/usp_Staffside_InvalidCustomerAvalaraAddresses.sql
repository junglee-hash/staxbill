
CREATE   PROCEDURE [dbo].[usp_Staffside_InvalidCustomerAvalaraAddresses]
	@AccountId BIGINT
AS

SELECT DISTINCT
c.Id AS [Stax Bill ID],
c.FirstName,
c.LastName,
c.Reference,
c.CompanyName
FROM [Address] addr
INNER JOIN Customer c ON c.id = addr.CustomerAddressPreferenceId

WHERE addr.Invalid = 1
AND c.AccountId = @AccountId
And c.IsDeleted = 0

GO

