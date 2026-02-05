CREATE PROC [dbo].[usp_UpdateProductCustomField]

	@Id bigint,
	@ProductId bigint,
	@CustomFieldId bigint,
	@DefaultStringValue nvarchar(1000),
	@DefaultDateValue datetime,
	@DefaultNumericValue decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [ProductCustomField] SET 
		[ProductId] = @ProductId,
		[CustomFieldId] = @CustomFieldId,
		[DefaultStringValue] = @DefaultStringValue,
		[DefaultDateValue] = @DefaultDateValue,
		[DefaultNumericValue] = @DefaultNumericValue,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

