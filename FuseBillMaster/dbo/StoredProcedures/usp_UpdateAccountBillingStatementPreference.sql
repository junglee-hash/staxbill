CREATE PROC [dbo].[usp_UpdateAccountBillingStatementPreference]

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
	@TrackedItemNameFieldOverride nvarchar(100),
	@TrackedItemReferenceFieldOverride nvarchar(100),
	@TrackedItemDescriptionFieldOverride nvarchar(100),
	@TrackedItemCreatedDateFieldOverride nvarchar(100),
	@TrackedItemPageLabelOverride nvarchar(100),
	@TrackedItemMainInvoiceMessage nvarchar(500),
	@StatementActivityTypeId int,
	@ShowWordStatement bit
AS
SET NOCOUNT ON
	UPDATE [AccountBillingStatementPreference] SET 
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
		[TrackedItemNameFieldOverride] = @TrackedItemNameFieldOverride,
		[TrackedItemReferenceFieldOverride] = @TrackedItemReferenceFieldOverride,
		[TrackedItemDescriptionFieldOverride] = @TrackedItemDescriptionFieldOverride,
		[TrackedItemCreatedDateFieldOverride] = @TrackedItemCreatedDateFieldOverride,
		[TrackedItemPageLabelOverride] = @TrackedItemPageLabelOverride,
		[TrackedItemMainInvoiceMessage] = @TrackedItemMainInvoiceMessage,
		[StatementActivityTypeId] = @StatementActivityTypeId,
		[ShowWordStatement] = @ShowWordStatement
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

