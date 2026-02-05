CREATE PROC [dbo].[usp_InsertCustomerInvoiceSetting]

	@Id bigint,
	@RollUpTaxes bit,
	@ShowTrackedItemName bit,
	@ShowTrackedItemReference bit,
	@ShowTrackedItemDescription bit,
	@ShowTrackedItemCreatedDate bit,
	@TrackedItemDisplayFormatId int,
	@RollUpDiscounts bit,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [CustomerInvoiceSetting] (
		[Id],
		[RollUpTaxes],
		[ShowTrackedItemName],
		[ShowTrackedItemReference],
		[ShowTrackedItemDescription],
		[ShowTrackedItemCreatedDate],
		[TrackedItemDisplayFormatId],
		[RollUpDiscounts],
		[ModifiedTimestamp]
	)
	VALUES (
		@Id,
		@RollUpTaxes,
		@ShowTrackedItemName,
		@ShowTrackedItemReference,
		@ShowTrackedItemDescription,
		@ShowTrackedItemCreatedDate,
		@TrackedItemDisplayFormatId,
		@RollUpDiscounts,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

