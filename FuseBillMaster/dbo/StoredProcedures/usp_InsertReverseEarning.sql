 
 
CREATE PROC [dbo].[usp_InsertReverseEarning]

	@Id bigint,
	@ReverseChargeId bigint,
	@Reference nvarchar(500)
AS
SET NOCOUNT ON
	INSERT INTO [ReverseEarning] (
		[Id],
		[ReverseChargeId],
		[Reference]
	)
	VALUES (
		@Id,
		@ReverseChargeId,
		@Reference
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

