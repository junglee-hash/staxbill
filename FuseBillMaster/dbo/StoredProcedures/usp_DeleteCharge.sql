CREATE PROC [dbo].[usp_DeleteCharge]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Charge]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

