CREATE PROC [dbo].[usp_InsertCustomerBillingStatementSetting]

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
	INSERT INTO [CustomerBillingStatementSetting] (
		[Id],
		[OptionId],
		[TypeId],
		[IntervalId],
		[Day],
		[Month],
		[ShowTrackedItemName],
		[ShowTrackedItemReference],
		[ShowTrackedItemDescription],
		[TrackedItemDisplayFormatId],
		[ShowTrackedItemCreatedDate],
		[ModifiedTimestamp]
	)
	VALUES (
		@Id,
		@OptionId,
		@TypeId,
		@IntervalId,
		@Day,
		@Month,
		@ShowTrackedItemName,
		@ShowTrackedItemReference,
		@ShowTrackedItemDescription,
		@TrackedItemDisplayFormatId,
		@ShowTrackedItemCreatedDate,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

