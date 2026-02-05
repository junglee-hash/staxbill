 
 
CREATE PROC [dbo].[usp_InsertDefaultEmailSchedule]

	@Type varchar(50),
	@DaysFromTerm int
AS
SET NOCOUNT ON
	INSERT INTO [DefaultEmailSchedule] (
		[Type],
		[DaysFromTerm]
	)
	VALUES (
		@Type,
		@DaysFromTerm
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

