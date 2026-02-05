 
 
CREATE PROC [dbo].[usp_InsertPlanProductFrequencyCustomField]

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
	INSERT INTO [PlanProductFrequencyCustomField] (
		[PlanProductUniqueId],
		[PlanFrequencyUniqueId],
		[CustomFieldId],
		[DefaultStringValue],
		[DefaultDateValue],
		[DefaultNumericValue],
		[CreatedTimestamp],
		[ModifiedTimestamp]
	)
	VALUES (
		@PlanProductUniqueId,
		@PlanFrequencyUniqueId,
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

