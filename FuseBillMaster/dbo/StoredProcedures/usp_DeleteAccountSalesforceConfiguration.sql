CREATE PROC [dbo].[usp_DeleteAccountSalesforceConfiguration]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountSalesforceConfiguration]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

