CREATE PROC [dbo].[usp_UpdateReverseEarning]

	@Id bigint,
	@ReverseChargeId bigint,
	@Reference nvarchar(500)
AS
SET NOCOUNT ON
	UPDATE [ReverseEarning] SET 
		[ReverseChargeId] = @ReverseChargeId,
		[Reference] = @Reference
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

