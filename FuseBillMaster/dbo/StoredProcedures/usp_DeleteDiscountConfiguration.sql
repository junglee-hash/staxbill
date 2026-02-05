CREATE PROC [dbo].[usp_DeleteDiscountConfiguration]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [DiscountConfiguration]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

