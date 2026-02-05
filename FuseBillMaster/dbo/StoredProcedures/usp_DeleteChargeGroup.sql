CREATE PROC [dbo].[usp_DeleteChargeGroup]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [ChargeGroup]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

