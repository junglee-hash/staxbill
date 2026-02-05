 
 
CREATE PROC [dbo].[usp_InsertSubscriptionCustomField]

	@CustomFieldId bigint,
	@SubscriptionId bigint,
	@StringValue nvarchar(1000),
	@DateValue datetime,
	@NumericValue decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [SubscriptionCustomField] (
		[CustomFieldId],
		[SubscriptionId],
		[StringValue],
		[DateValue],
		[NumericValue],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@CustomFieldId,
		@SubscriptionId,
		@StringValue,
		@DateValue,
		@NumericValue,
		@CreatedTimestamp,
		@ModifiedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

