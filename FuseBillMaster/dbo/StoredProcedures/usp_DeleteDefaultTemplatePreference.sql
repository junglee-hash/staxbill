CREATE PROC [dbo].[usp_DeleteDefaultTemplatePreference]
	@Id bigint
AS
SET NOCOUNT ON

DELETE FROM [DefaultTemplatePreference]
WHERE [Id] = @Id

SET NOCOUNT OFF

GO

