CREATE PROC [dbo].[usp_DeleteCustomer]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Customer]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

