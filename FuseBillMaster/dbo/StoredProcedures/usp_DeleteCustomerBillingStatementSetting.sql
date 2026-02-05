CREATE PROC [dbo].[usp_DeleteCustomerBillingStatementSetting]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerBillingStatementSetting]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

