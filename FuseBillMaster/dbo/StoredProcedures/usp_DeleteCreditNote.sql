CREATE PROC [dbo].[usp_DeleteCreditNote]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [CreditNote]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

