CREATE PROC [dbo].[usp_DeleteCustomerEmailPreference]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerEmailPreference]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

