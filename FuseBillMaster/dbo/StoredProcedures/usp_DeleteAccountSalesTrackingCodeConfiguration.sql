CREATE PROC [dbo].[usp_DeleteAccountSalesTrackingCodeConfiguration]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountSalesTrackingCodeConfiguration]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

