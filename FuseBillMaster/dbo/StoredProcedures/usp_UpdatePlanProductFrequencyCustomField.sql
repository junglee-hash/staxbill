CREATE PROC [dbo].[usp_UpdatePlanProductFrequencyCustomField]

	@Id bigint,
	@PlanProductUniqueId bigint,
	@PlanFrequencyUniqueId bigint,
	@CustomFieldId bigint,
	@DefaultStringValue nvarchar(1000),
	@DefaultDateValue datetime,
	@DefaultNumericValue decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [PlanProductFrequencyCustomField] SET 
		[PlanProductUniqueId] = @PlanProductUniqueId,
		[PlanFrequencyUniqueId] = @PlanFrequencyUniqueId,
		[CustomFieldId] = @CustomFieldId,
		[DefaultStringValue] = @DefaultStringValue,
		[DefaultDateValue] = @DefaultDateValue,
		[DefaultNumericValue] = @DefaultNumericValue,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

