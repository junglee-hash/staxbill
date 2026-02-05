CREATE PROCEDURE [dbo].[usp_GlobalAccountSearch]
	--declare
	@SearchTerm nvarchar(50)
AS

	SET NOCOUNT ON;

SELECT DISTINCT TOP 6 
		ac.*,
		ac.TypeId as [Type]
FROM Account ac
        inner join AccountUser au on au.AccountId = ac.Id
        inner join [User] u on u.id = au.UserId
        inner join [Credential] cred on cred.UserId = u.Id
        WHERE (
        ac.Id like @SearchTerm
        OR ac.[ContactEmail] like @SearchTerm
        OR ac.[CompanyName] like @SearchTerm
        OR u.Email like @SearchTerm
        OR concat(u.FirstName, ' ', u.LastName) like @SearchTerm
        OR cred.Username like @SearchTerm
		OR ac.FusebillIncId like @SearchTerm)
        ORDER BY ac.Id

GO

