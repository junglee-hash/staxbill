CREATE PROC [dbo].[usp_DeleteCollectionScheduleActivity]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CollectionScheduleActivity]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

