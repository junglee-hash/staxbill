CREATE PROC [dbo].[usp_DeleteTaxRule]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [TaxRule]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

