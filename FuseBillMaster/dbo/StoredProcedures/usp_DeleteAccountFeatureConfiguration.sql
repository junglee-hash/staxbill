CREATE PROC [dbo].[usp_DeleteAccountFeatureConfiguration]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [AccountFeatureConfiguration]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

