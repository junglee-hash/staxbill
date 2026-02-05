

CREATE procedure [dbo].[usp_InsertFusebillPreviewLogin]
	@AccountId bigint,
	@userId bigint,
	@forDevice bit
AS

declare @userIdFound bit

SELECT
	@userIdFound = Count(Id)
FROM
	[dbo].[User]
WHERE
	Id = @userId
	
IF @userIdFound > 0
BEGIN
	DECLARE @token uniqueidentifier = newid()
	INSERT INTO [dbo].[FusebillPreviewLogin]
			   ([Token]
			   ,[UserId]
			   ,[CreatedTimestamp]
			   ,[Consumed]
			   ,[AccountId]
			   ,[ForDevice])
		 VALUES
			   (@token
			   ,@userId
			   ,getutcdate()
			   ,0
			   ,@AccountId
			   ,@forDevice)

	SELECT @token
END

GO

