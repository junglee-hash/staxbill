CREATE PROC [dbo].[usp_DeleteFusebillSupportUser]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [FusebillSupportUser]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

