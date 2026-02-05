 
 
CREATE PROC [dbo].[usp_InsertPlanFrequencyKey]

	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [PlanFrequencyKey] (
		[CreatedTimestamp]
	)
	VALUES (
		@CreatedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

