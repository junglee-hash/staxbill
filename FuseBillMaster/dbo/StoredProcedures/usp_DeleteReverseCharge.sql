CREATE PROC [dbo].[usp_DeleteReverseCharge]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [ReverseCharge]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

