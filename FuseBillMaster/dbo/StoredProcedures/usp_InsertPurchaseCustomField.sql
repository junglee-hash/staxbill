 
 
CREATE PROC [dbo].[usp_InsertPurchaseCustomField]

	@CustomFieldId bigint,
	@PurchaseId bigint,
	@StringValue nvarchar(1000),
	@DateValue datetime,
	@NumericValue decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [PurchaseCustomField] (
		[CustomFieldId],
		[PurchaseId],
		[StringValue],
		[DateValue],
		[NumericValue],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@CustomFieldId,
		@PurchaseId,
		@StringValue,
		@DateValue,
		@NumericValue,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

