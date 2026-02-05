 
 
CREATE PROC [dbo].[usp_InsertDebit]

	@Id bigint,
	@Reference nvarchar(500),
	@OriginalCreditId bigint
AS
SET NOCOUNT ON
	INSERT INTO [Debit] (
		[Id],
		[Reference],
		[OriginalCreditId]
	)
	VALUES (
		@Id,
		@Reference,
		@OriginalCreditId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

