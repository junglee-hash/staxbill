CREATE PROC [dbo].[usp_UpdateEarning]

	@Id bigint,
	@ChargeId bigint,
	@Reference nvarchar(500)
AS
SET NOCOUNT ON
	UPDATE [Earning] SET 
		[ChargeId] = @ChargeId,
		[Reference] = @Reference
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

