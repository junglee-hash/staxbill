
CREATE PROCEDURE [dbo].[usp_ConsumeHubSpotToken]
--Declare
	@AccountId bigint,
	@Token uniqueidentifier
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	SET NOCOUNT ON;

	DELETE hat
	FROM [dbo].[HubSpotAuthenticationToken] hat
	WHERE hat.AccountId = @AccountId
		AND (hat.Token = @Token OR hat.CreatedTimestamp < DATEADD(DAY, -1, GETUTCDATE()))


END

GO

