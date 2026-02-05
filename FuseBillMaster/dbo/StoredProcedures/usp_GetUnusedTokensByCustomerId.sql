
CREATE    PROCEDURE [dbo].[usp_GetUnusedTokensByCustomerId]
	@TokenTypeId BIGINT
	, @CustomerId BIGINT

AS
BEGIN

SET TRANSACTION ISOLATION LEVEL SNAPSHOT
SET NOCOUNT ON;

SELECT 
	 *,
	 sspt.TokenTypeID as tokentype
	 from SelfServicePortalToken sspt
	 WHERE IsConsumed = 0
	 AND TokenTypeID = @TokenTypeId
	 AND CustomerId = @CustomerId
	 AND CreatedTimestamp < DATEADD(MINUTE, -30, GETUTCDATE())


END

GO

