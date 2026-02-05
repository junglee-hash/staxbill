CREATE PROC [dbo].[usp_DeleteDefaultCollectionSchedule]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [DefaultCollectionSchedule]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

