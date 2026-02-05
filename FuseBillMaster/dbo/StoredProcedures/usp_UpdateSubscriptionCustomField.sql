CREATE PROC [dbo].[usp_UpdateSubscriptionCustomField]

	@Id bigint,
	@CustomFieldId bigint,
	@SubscriptionId bigint,
	@StringValue nvarchar(1000),
	@DateValue datetime,
	@NumericValue decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [SubscriptionCustomField] SET 
		[CustomFieldId] = @CustomFieldId,
		[SubscriptionId] = @SubscriptionId,
		[StringValue] = @StringValue,
		[DateValue] = @DateValue,
		[NumericValue] = @NumericValue,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

