CREATE PROC [dbo].[usp_DeleteSalesTrackingCode]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [SalesTrackingCode]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

