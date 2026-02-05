CREATE PROC [dbo].[usp_UpdatePlanFrequencyCustomField]

	@Id bigint,
	@CustomFieldId bigint,
	@DefaultStringValue nvarchar(1000),
	@DefaultDateValue datetime,
	@DefaultNumericValue decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@PlanFrequencyUniqueId bigint
AS
SET NOCOUNT ON
	UPDATE [PlanFrequencyCustomField] SET 
		[CustomFieldId] = @CustomFieldId,
		[DefaultStringValue] = @DefaultStringValue,
		[DefaultDateValue] = @DefaultDateValue,
		[DefaultNumericValue] = @DefaultNumericValue,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[PlanFrequencyUniqueId] = @PlanFrequencyUniqueId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

