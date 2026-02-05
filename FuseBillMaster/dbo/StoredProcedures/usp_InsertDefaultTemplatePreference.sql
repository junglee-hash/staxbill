 
 
CREATE PROC [dbo].[usp_InsertDefaultTemplatePreference]

	@Type bigint,
	@Name nvarchar(50),
	@Value nvarchar(Max)
AS
SET NOCOUNT ON
	INSERT INTO [DefaultTemplatePreference] (
		[Type],
		[Name],
		[Value]
	)
	VALUES (
		@Type,
		@Name,
		@Value
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

