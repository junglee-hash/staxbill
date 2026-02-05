 
 
CREATE PROC [dbo].[usp_InsertSubscriptionProductCustomField]

	@SubscriptionProductId bigint,
	@CustomFieldId bigint,
	@StringValue nvarchar(1000),
	@DateValue datetime,
	@NumericValue decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [SubscriptionProductCustomField] (
		[SubscriptionProductId],
		[CustomFieldId],
		[StringValue],
		[DateValue],
		[NumericValue],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@SubscriptionProductId,
		@CustomFieldId,
		@StringValue,
		@DateValue,
		@NumericValue,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

