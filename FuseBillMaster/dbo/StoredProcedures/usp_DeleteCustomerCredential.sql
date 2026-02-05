CREATE PROC [dbo].[usp_DeleteCustomerCredential]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerCredential]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

