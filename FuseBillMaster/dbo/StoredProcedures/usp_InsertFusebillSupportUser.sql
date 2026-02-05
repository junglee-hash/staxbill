 
 
CREATE PROC [dbo].[usp_InsertFusebillSupportUser]

	@ActiveDirectoryUsername nvarchar(255),
	@UserId bigint
AS
SET NOCOUNT ON
	INSERT INTO [FusebillSupportUser] (
		[ActiveDirectoryUsername],
		[UserId]
	)
	VALUES (
		@ActiveDirectoryUsername,
		@UserId
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

