CREATE PROC [dbo].[usp_DeleteQuantityRange]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [QuantityRange]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

