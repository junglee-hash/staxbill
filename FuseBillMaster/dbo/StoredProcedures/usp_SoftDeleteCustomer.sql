
CREATE PROCEDURE [dbo].[usp_SoftDeleteCustomer]
	@Id bigint
AS

SET NOCOUNT ON

UPDATE [Customer]
SET IsDeleted = 1,
ModifiedTimestamp = GETUTCDATE()
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

