 
 
CREATE PROC [dbo].[usp_InsertDefaultCollectionSchedule]

	@Day int
AS
SET NOCOUNT ON
	INSERT INTO [DefaultCollectionSchedule] (
		[Day]
	)
	VALUES (
		@Day
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

