 
 
CREATE PROC [dbo].[usp_InsertPlanProductKey]

	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	INSERT INTO [PlanProductKey] (
		[CreatedTimestamp]
	)
	VALUES (
		@CreatedTimestamp
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

