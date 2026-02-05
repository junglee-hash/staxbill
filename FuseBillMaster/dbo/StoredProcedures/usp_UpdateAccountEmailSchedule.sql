
CREATE PROC [dbo].[usp_UpdateAccountEmailSchedule]

	@Id bigint,
	@AccountId bigint,
	@Type varchar(50),
	@DaysFromTerm int,
	@Key varchar(60),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@AccountEmailTemplateContentId bigint
AS
SET NOCOUNT ON
	UPDATE [AccountEmailSchedule] SET 
		[AccountId] = @AccountId,
		[Type] = @Type,
		[DaysFromTerm] = @DaysFromTerm,
		[Key] = @Key,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[AccountEmailTemplateContentId] = @AccountEmailTemplateContentId 
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

