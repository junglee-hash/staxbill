 
 
CREATE PROC [dbo].[usp_InsertProductCustomField]

	@ProductId bigint,
	@CustomFieldId bigint,
	@DefaultStringValue nvarchar(1000),
	@DefaultDateValue datetime,
	@DefaultNumericValue decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [ProductCustomField] (
		[ProductId],
		[CustomFieldId],
		[DefaultStringValue],
		[DefaultDateValue],
		[DefaultNumericValue],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@ProductId,
		@CustomFieldId,
		@DefaultStringValue,
		@DefaultDateValue,
		@DefaultNumericValue,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

