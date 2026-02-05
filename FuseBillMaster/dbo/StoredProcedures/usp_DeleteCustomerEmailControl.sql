CREATE PROC [dbo].[usp_DeleteCustomerEmailControl]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerEmailControl]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

