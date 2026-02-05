CREATE PROC [dbo].[usp_DeleteAddress]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Address]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

