
CREATE     PROCEDURE [dbo].[usp_DeleteAccountGeotabDevicePlan]
	@Id BIGINT
AS
BEGIN

DELETE FROM dbo.AccountGeotabDevicePlan 
WHERE ID = @Id

END

GO

