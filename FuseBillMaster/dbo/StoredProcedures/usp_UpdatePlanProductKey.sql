CREATE PROC [dbo].[usp_UpdatePlanProductKey]

	@Id bigint,
	@CreatedTimestamp datetime
AS
SET NOCOUNT ON
	UPDATE [PlanProductKey] SET 
		[CreatedTimestamp] = @CreatedTimestamp
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

