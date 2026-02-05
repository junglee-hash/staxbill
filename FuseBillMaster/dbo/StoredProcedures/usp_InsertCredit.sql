 
 
CREATE PROC [dbo].[usp_InsertCredit]

	@Id bigint,
	@Reference nvarchar(255),
	@UnallocatedAmount decimal,
	@ReversableAmount decimal
AS
SET NOCOUNT ON
	INSERT INTO [Credit] (
		[Id],
		[Reference],
		[UnallocatedAmount],
		[ReversableAmount]
	)
	VALUES (
		@Id,
		@Reference,
		@UnallocatedAmount,
		@ReversableAmount
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

