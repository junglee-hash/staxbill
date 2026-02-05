
/*********************************************************************************
[usp_GetFusebillSupportLogin]


Inputs:
@Token uniqueidentifier

Work:
Returns an unconsumed, non-expired record from the FusebillSupportLogin table using the @Token or nothing.
If found, it marks the record as consumed. 

Tokens are only active for 10 seconds.

*********************************************************************************/
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetFusebillSupportLogin] 
	@Token uniqueidentifier
AS
BEGIN
	DECLARE @id int
	DECLARE @userId bigint
	DECLARE @accountId bigint
	DECLARE @customerId bigint

	SELECT
		@id = Id,
		@userId = UserId,
		@accountId = AccountId,
		@customerId = CustomerId
	FROM 
		[dbo].[FusebillSupportLogin]
	WHERE
		Token = @Token
		AND Consumed = 0
		AND DATEDIFF(SECOND, CreatedTimestamp, getutcdate()) < 10

	IF @userId is not null
	BEGIN
		UPDATE [dbo].[FusebillSupportLogin]
		SET Consumed = 1
		WHERE Id = @id
	END

	SELECT 
		@accountId as AccountId, 
		@userId as UserId, 
		Email as UserEmail,
		@customerId as CustomerId
	FROM [dbo].[User]
	WHERE Id = @userId
END

GO

