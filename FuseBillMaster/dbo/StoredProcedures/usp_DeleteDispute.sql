CREATE PROC [dbo].[usp_DeleteDispute]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [Dispute]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

