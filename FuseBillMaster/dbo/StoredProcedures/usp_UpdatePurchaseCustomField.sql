CREATE PROC [dbo].[usp_UpdatePurchaseCustomField]

	@Id bigint,
	@CustomFieldId bigint,
	@PurchaseId bigint,
	@StringValue nvarchar(1000),
	@DateValue datetime,
	@NumericValue decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [PurchaseCustomField] SET 
		[CustomFieldId] = @CustomFieldId,
		[PurchaseId] = @PurchaseId,
		[StringValue] = @StringValue,
		[DateValue] = @DateValue,
		[NumericValue] = @NumericValue,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

