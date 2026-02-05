CREATE PROC [dbo].[usp_DeleteAccountBillingPeriodConfiguration]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountBillingPeriodConfiguration]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

