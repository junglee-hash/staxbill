CREATE PROC [dbo].[usp_DeleteOrderToCashCycle]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [OrderToCashCycle]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

