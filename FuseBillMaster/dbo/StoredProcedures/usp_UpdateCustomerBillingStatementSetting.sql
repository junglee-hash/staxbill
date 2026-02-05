CREATE PROC [dbo].[usp_UpdateCustomerBillingStatementSetting]

	@Id bigint,
	@OptionId int,
	@TypeId int,
	@IntervalId int,
	@Day int,
	@Month int,
	@ShowTrackedItemName bit,
	@ShowTrackedItemReference bit,
	@ShowTrackedItemDescription bit,
	@TrackedItemDisplayFormatId int,
	@ShowTrackedItemCreatedDate bit,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [CustomerBillingStatementSetting] SET 
		[OptionId] = @OptionId,
		[TypeId] = @TypeId,
		[IntervalId] = @IntervalId,
		[Day] = @Day,
		[Month] = @Month,
		[ShowTrackedItemName] = @ShowTrackedItemName,
		[ShowTrackedItemReference] = @ShowTrackedItemReference,
		[ShowTrackedItemDescription] = @ShowTrackedItemDescription,
		[TrackedItemDisplayFormatId] = @TrackedItemDisplayFormatId,
		[ShowTrackedItemCreatedDate] = @ShowTrackedItemCreatedDate,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

