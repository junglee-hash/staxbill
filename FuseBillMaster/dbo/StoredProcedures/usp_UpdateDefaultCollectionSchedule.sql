CREATE PROC [dbo].[usp_UpdateDefaultCollectionSchedule]

	@Id bigint,
	@Day int
AS
SET NOCOUNT ON
	UPDATE [DefaultCollectionSchedule] SET 
		[Day] = @Day
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

