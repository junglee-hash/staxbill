CREATE PROC [dbo].[usp_DeleteDefaultEmailSchedule]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [DefaultEmailSchedule]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

