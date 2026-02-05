
/*********************************************************************************
[]


Inputs:
@ADUsername nvarchar(255)

Work:
Inserts a record into FusebillSupportLogin joining to retrieve the user ID.
Returns null if the AD User does not have a Fusebill User.

Outputs:
A login token


*********************************************************************************/
CREATE procedure [dbo].[usp_InsertFusebillSupportLogin]
	@AccountId bigint,
	@ADUsername nvarchar(255),
	@CustomerId bigint
AS

DECLARE @userId bigint

SELECT
	@userId = UserId
FROM
	[dbo].[FusebillSupportUser]
WHERE
	ActiveDirectoryUsername = @ADUsername
	
IF @userId is not null
BEGIN
	DECLARE @token uniqueidentifier = newid()
	INSERT INTO [dbo].[FusebillSupportLogin]
			   ([Token]
			   ,[UserId]
			   ,[CreatedTimestamp]
			   ,[Consumed]
			   ,[AccountId]
			   ,[CustomerId])
		 VALUES
			   (@token
			   ,@userId
			   ,getutcdate()
			   ,0
			   ,@AccountId,
			   @CustomerId)

	SELECT @token
END
ELSE
BEGIN
	SELECT @userId
END

GO

