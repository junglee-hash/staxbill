CREATE PROC [dbo].[usp_InsertAccountBillingStatementPreference]

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
	@ShowWordStatement bit
AS
SET NOCOUNT ON
	INSERT INTO [AccountBillingStatementPreference] (
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
		[TrackedItemNameFieldOverride],
		[TrackedItemReferenceFieldOverride],
		[TrackedItemDescriptionFieldOverride],
		[TrackedItemCreatedDateFieldOverride],
		[TrackedItemPageLabelOverride],
		[TrackedItemMainInvoiceMessage],
		[ShowWordStatement]
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
		@TrackedItemNameFieldOverride,
		@TrackedItemReferenceFieldOverride,
		@TrackedItemDescriptionFieldOverride,
		@TrackedItemCreatedDateFieldOverride,
		@TrackedItemPageLabelOverride,
		@TrackedItemMainInvoiceMessage,
		@ShowWordStatement
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

