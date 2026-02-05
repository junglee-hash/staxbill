CREATE   PROCEDURE [dbo].[usp_GlobalCustomerSearchNonAlphabetic]
	--declare
	@SearchTerm nvarchar(50), 
	@AccountId bigint 
AS
		SELECT TOP 6 
				Id
				,Reference
				,FirstName
				,LastName
				,CompanyName
				,PrimaryEmail
				FROM Customer
				WHERE AccountId = @AccountId
				AND IsDeleted = 0
				AND (
				Customer.Id like @SearchTerm
				OR Customer.FirstName like @SearchTerm
				OR Customer.LastName like @SearchTerm
				OR Customer.PrimaryEmail like @SearchTerm
				OR Customer.CompanyName like @SearchTerm
				OR Customer.Reference like @SearchTerm)

GO

