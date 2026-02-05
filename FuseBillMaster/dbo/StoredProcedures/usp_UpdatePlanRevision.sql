CREATE PROC [dbo].[usp_UpdatePlanRevision]

	@Id bigint,
	@CreatedTimestamp datetime,
	@PlanId bigint,
	@IsActive bit
AS
SET NOCOUNT ON
	UPDATE [PlanRevision] SET 
		[CreatedTimestamp] = @CreatedTimestamp,
		[PlanId] = @PlanId,
		[IsActive] = @IsActive
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

