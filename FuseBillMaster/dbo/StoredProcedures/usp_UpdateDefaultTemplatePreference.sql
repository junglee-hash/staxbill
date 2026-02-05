CREATE PROC [dbo].[usp_UpdateDefaultTemplatePreference]

	@Id bigint,
	@Type bigint,
	@Name nvarchar(50),
	@Value nvarchar(Max)
AS
SET NOCOUNT ON
	UPDATE [DefaultTemplatePreference] SET 
		[Type] = @Type,
		[Name] = @Name,
		[Value] = @Value
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

