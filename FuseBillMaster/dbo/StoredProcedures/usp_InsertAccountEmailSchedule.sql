
CREATE PROC [dbo].[usp_InsertAccountEmailSchedule]

	@AccountId bigint,
	@Type varchar(50),
	@DaysFromTerm int,
	@Key varchar(60),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@AccountEmailTemplateContentId bigint
AS
SET NOCOUNT ON
	INSERT INTO [AccountEmailSchedule] (
		[AccountId],
		[Type],
		[DaysFromTerm],
		[Key],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[AccountEmailTemplateContentId]
	)
	VALUES (
		@AccountId,
		@Type,
		@DaysFromTerm,
		@Key,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@AccountEmailTemplateContentId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

