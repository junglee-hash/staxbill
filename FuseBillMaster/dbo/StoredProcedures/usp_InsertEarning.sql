 
 
CREATE PROC [dbo].[usp_InsertEarning]

	@Id bigint,
	@ChargeId bigint,
	@Reference nvarchar(500)
AS
SET NOCOUNT ON
	INSERT INTO [Earning] (
		[Id],
		[ChargeId],
		[Reference]
	)
	VALUES (
		@Id,
		@ChargeId,
		@Reference
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

