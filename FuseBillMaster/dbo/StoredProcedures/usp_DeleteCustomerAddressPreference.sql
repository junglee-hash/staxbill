CREATE PROC [dbo].[usp_DeleteCustomerAddressPreference]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerAddressPreference]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

