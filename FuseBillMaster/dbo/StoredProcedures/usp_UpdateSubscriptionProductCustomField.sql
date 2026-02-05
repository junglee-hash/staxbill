CREATE PROC [dbo].[usp_UpdateSubscriptionProductCustomField]

	@Id bigint,
	@SubscriptionProductId bigint,
	@CustomFieldId bigint,
	@StringValue nvarchar(1000),
	@DateValue datetime,
	@NumericValue decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [SubscriptionProductCustomField] SET 
		[SubscriptionProductId] = @SubscriptionProductId,
		[CustomFieldId] = @CustomFieldId,
		[StringValue] = @StringValue,
		[DateValue] = @DateValue,
		[NumericValue] = @NumericValue,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

