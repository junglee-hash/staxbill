CREATE PROC [dbo].[usp_UpdateDebit]

	@Id bigint,
	@Reference nvarchar(500),
	@OriginalCreditId bigint
AS
SET NOCOUNT ON
	UPDATE [Debit] SET 
		[Reference] = @Reference,
		[OriginalCreditId] = @OriginalCreditId
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

