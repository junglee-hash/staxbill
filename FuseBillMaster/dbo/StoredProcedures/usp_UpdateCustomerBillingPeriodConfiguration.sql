CREATE PROC [dbo].[usp_UpdateCustomerBillingPeriodConfiguration]

	@Id bigint,
	@CustomerBillingSettingId bigint,
	@IntervalId int,
	@Month int,
	@Day int,
	@TypeId int,
	@RuleId int,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [CustomerBillingPeriodConfiguration] SET 
		[CustomerBillingSettingId] = @CustomerBillingSettingId,
		[IntervalId] = @IntervalId,
		[Month] = @Month,
		[Day] = @Day,
		[TypeId] = @TypeId,
		[RuleId] = @RuleId,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

