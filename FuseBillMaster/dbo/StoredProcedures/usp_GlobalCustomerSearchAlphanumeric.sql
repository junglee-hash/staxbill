CREATE   PROCEDURE [dbo].[usp_GlobalCustomerSearchAlphanumeric] 
	--declare
	@SearchTerm nvarchar(50), 
	@AccountId bigint 
AS
	SET NOCOUNT ON;

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
			--because we only use this sproc if the search term has at least some letters, 
			--we skip checking customer.id which can only be numeric
			Customer.FirstName like @SearchTerm
			OR Customer.LastName like @SearchTerm
			OR Customer.PrimaryEmail like @SearchTerm
			OR Customer.CompanyName like @SearchTerm
			OR Customer.Reference like @SearchTerm)

GO

