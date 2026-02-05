CREATE PROC [dbo].[usp_DeleteDiscount]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Discount]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

