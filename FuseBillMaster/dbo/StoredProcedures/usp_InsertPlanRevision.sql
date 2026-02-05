 
 
CREATE PROC [dbo].[usp_InsertPlanRevision]

	@CreatedTimestamp datetime,
	@PlanId bigint,
	@IsActive bit
AS
SET NOCOUNT ON
	INSERT INTO [PlanRevision] (
		[CreatedTimestamp],
		[PlanId],
		[IsActive]
	)
	VALUES (
		@CreatedTimestamp,
		@PlanId,
		@IsActive
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

