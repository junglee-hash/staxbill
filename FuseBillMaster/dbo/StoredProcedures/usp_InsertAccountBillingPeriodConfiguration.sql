CREATE PROC [dbo].[usp_InsertAccountBillingPeriodConfiguration]

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
	INSERT INTO [AccountBillingPeriodConfiguration] (
		[AccountBillingPreferenceId],
		[IntervalId],
		[Month],
		[Day],
		[Weekday],
		[TypeId],
		[RuleId],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@AccountBillingPreferenceId,
		@IntervalId,
		@Month,
		@Day,
		@Weekday,
		@TypeId,
		@RuleId,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

