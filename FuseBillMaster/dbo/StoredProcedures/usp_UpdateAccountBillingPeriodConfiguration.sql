CREATE PROC [dbo].[usp_UpdateAccountBillingPeriodConfiguration]

	@Id bigint,
	@AccountBillingPreferenceId bigint,
	@IntervalId int,
	@Month int,
	@Day int,
	@Weekday int = null,
	@TypeId int,
	@RuleId int,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [AccountBillingPeriodConfiguration] SET 
		[AccountBillingPreferenceId] = @AccountBillingPreferenceId,
		[IntervalId] = @IntervalId,
		[Month] = @Month,
		[Day] = @Day,
		[Weekday] = @Weekday,
		[TypeId] = @TypeId,
		[RuleId] = @RuleId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

