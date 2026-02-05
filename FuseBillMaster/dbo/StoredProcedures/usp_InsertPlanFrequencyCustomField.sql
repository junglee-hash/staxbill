 
 
CREATE PROC [dbo].[usp_InsertPlanFrequencyCustomField]

	@CustomFieldId bigint,
	@DefaultStringValue nvarchar(1000),
	@DefaultDateValue datetime,
	@DefaultNumericValue decimal,
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@PlanFrequencyUniqueId bigint
AS
SET NOCOUNT ON
	INSERT INTO [PlanFrequencyCustomField] (
		[CustomFieldId],
		[DefaultStringValue],
		[DefaultDateValue],
		[DefaultNumericValue],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[PlanFrequencyUniqueId]
	)
	VALUES (
		@CustomFieldId,
		@DefaultStringValue,
		@DefaultDateValue,
		@DefaultNumericValue,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@PlanFrequencyUniqueId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

