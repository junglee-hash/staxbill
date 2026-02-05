CREATE PROC [dbo].[usp_UpdateOpeningBalance]

	@Id bigint,
	@Reference nvarchar(500),
	@UnallocatedAmount decimal
AS
SET NOCOUNT ON
	UPDATE [OpeningBalance] SET 
		[Reference] = @Reference,
		[UnallocatedAmount] = @UnallocatedAmount
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

