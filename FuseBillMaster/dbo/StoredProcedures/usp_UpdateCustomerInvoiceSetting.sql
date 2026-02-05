CREATE PROC [dbo].[usp_UpdateCustomerInvoiceSetting]

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
	UPDATE [CustomerInvoiceSetting] SET 
		[RollUpTaxes] = @RollUpTaxes,
		[ShowTrackedItemName] = @ShowTrackedItemName,
		[ShowTrackedItemReference] = @ShowTrackedItemReference,
		[ShowTrackedItemDescription] = @ShowTrackedItemDescription,
		[ShowTrackedItemCreatedDate] = @ShowTrackedItemCreatedDate,
		[TrackedItemDisplayFormatId] = @TrackedItemDisplayFormatId,
		[RollUpDiscounts] = @RollUpDiscounts,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

