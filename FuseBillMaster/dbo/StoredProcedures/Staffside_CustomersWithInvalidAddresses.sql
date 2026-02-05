Create PROCEDURE [dbo].[Staffside_CustomersWithInvalidAddresses]
AS
BEGIN
	SET NOCOUNT ON;

	Select 
		acc.Id as [Account Id],
		acc.CompanyName as [Company Name],
		c.Id as [Fusebill Id],
		c.Reference [Customer Reference],
		Concat(ISNULL(c.FirstName,''),' ',ISNULL(c.LastName,'') ) as [Customer Name],
		adr.Country as [Country],
		adr.[State] as [State],
		adr.City as [City],
		adr.Line1 as [Address Line 1],
		adr.Line2 as [Address Line 2],
		adr.PostalZip as [Postal Code]
	from Customer c
		inner join [Address] adr on adr.CustomerAddressPreferenceId = c.Id
		inner join Account acc on acc.Id = c.AccountId
	where adr.Invalid = 1	

END

GO

