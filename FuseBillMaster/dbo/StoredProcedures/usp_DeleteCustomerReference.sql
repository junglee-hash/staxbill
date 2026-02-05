CREATE PROC [dbo].[usp_DeleteCustomerReference]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CustomerReference]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

