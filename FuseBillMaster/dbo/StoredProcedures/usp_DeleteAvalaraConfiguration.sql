CREATE PROC [dbo].[usp_DeleteAvalaraConfiguration]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AvalaraConfiguration]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

