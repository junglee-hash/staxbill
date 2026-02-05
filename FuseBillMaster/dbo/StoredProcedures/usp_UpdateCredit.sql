CREATE PROC [dbo].[usp_UpdateCredit]

	@Id bigint,
	@Reference nvarchar(255),
	@UnallocatedAmount decimal,
	@ReversableAmount decimal
AS
SET NOCOUNT ON
	UPDATE [Credit] SET 
		[Reference] = @Reference,
		[UnallocatedAmount] = @UnallocatedAmount,
		[ReversableAmount] = @ReversableAmount
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

