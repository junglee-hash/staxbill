CREATE PROC [dbo].[usp_DeleteEarningDiscount]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [EarningDiscount]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

