CREATE PROC [dbo].[usp_InsertAccountSalesforceConfiguration]

	@Id bigint,
	@DefaultAccountTypeId tinyint,
	@CurrentPackageVersion decimal(3,2) = null
AS
SET NOCOUNT ON
	INSERT INTO [AccountSalesforceConfiguration] (
		[Id],
		[DefaultAccountTypeId],
		[CurrentPackageVersion]
	)
	VALUES (
		@Id,
		@DefaultAccountTypeId,
		@CurrentPackageVersion
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

