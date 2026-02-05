CREATE PROC [dbo].[usp_DeleteCustomerNote]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerNote]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

