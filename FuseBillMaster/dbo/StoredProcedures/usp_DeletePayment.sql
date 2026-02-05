CREATE PROC [dbo].[usp_DeletePayment]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Payment]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

