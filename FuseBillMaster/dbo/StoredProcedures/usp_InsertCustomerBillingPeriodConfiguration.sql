 
 
CREATE PROC [dbo].[usp_InsertCustomerBillingPeriodConfiguration]

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
	INSERT INTO [CustomerBillingPeriodConfiguration] (
		[CustomerBillingSettingId],
		[IntervalId],
		[Month],
		[Day],
		[TypeId],
		[RuleId],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@CustomerBillingSettingId,
		@IntervalId,
		@Month,
		@Day,
		@TypeId,
		@RuleId,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

