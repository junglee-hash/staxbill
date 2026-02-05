CREATE PROC [dbo].[usp_DeleteReverseDiscount]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [ReverseDiscount]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

