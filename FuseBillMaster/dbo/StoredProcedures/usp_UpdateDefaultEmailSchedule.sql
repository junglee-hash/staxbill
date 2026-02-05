CREATE PROC [dbo].[usp_UpdateDefaultEmailSchedule]

	@Id bigint,
	@Type varchar(50),
	@DaysFromTerm int
AS
SET NOCOUNT ON
	UPDATE [DefaultEmailSchedule] SET 
		[Type] = @Type,
		[DaysFromTerm] = @DaysFromTerm
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

