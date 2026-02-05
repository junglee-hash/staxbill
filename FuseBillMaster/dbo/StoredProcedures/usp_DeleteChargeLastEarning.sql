CREATE PROC [dbo].[usp_DeleteChargeLastEarning]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [ChargeLastEarning]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

