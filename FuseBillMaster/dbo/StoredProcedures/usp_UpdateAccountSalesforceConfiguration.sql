CREATE PROC [dbo].[usp_UpdateAccountSalesforceConfiguration]

	@Id bigint,
	@DefaultAccountTypeId tinyint,
	@CurrentPackageVersion decimal(3,2) = null
AS
SET NOCOUNT ON
	UPDATE [AccountSalesforceConfiguration] 
	SET [DefaultAccountTypeId] = @DefaultAccountTypeId,
	[CurrentPackageVersion] = @CurrentPackageVersion
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

