 
 
CREATE PROC [dbo].[usp_InsertOpeningBalance]

	@Id bigint,
	@Reference nvarchar(500),
	@UnallocatedAmount decimal
AS
SET NOCOUNT ON
	INSERT INTO [OpeningBalance] (
		[Id],
		[Reference],
		[UnallocatedAmount]
	)
	VALUES (
		@Id,
		@Reference,
		@UnallocatedAmount
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

