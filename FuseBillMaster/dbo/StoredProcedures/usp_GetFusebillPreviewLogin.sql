
CREATE PROCEDURE [dbo].[usp_GetFusebillPreviewLogin] 
	@Token uniqueidentifier
AS
BEGIN
	DECLARE @id int
	DECLARE @userId bigint
	DECLARE @accountId bigint

	SELECT
		@id = Id,
		@userId = UserId,
		@accountId = AccountId
	FROM 
		[dbo].[FusebillPreviewLogin]
	WHERE
		Token = @Token
		AND Consumed = 0
		AND DATEDIFF(SECOND, CreatedTimestamp, getutcdate()) <  
			CASE ForDevice
				WHEN 0 THEN 15
				WHEN 1 THEN 43200 --12 hours
			End

	IF @userId is not null
	BEGIN
		UPDATE [dbo].[FusebillPreviewLogin]
		SET Consumed = 1
		WHERE Id = @id
	END

	SELECT 
		@accountId as AccountId, 
		@userId as UserId, 
		Email as UserEmail
	FROM [dbo].[User]
	WHERE Id = @userId
END

GO

