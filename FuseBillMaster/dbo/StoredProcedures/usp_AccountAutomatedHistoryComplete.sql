
CREATE PROCEDURE usp_AccountAutomatedHistoryComplete
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	update top (1000) [dbo].[AccountAutomatedHistory]
	set HasFinished = 1
	where CompletedTimestamp is null and datediff(HOUR, CreatedTimestamp, GETUTCDATE()) > 48
END

GO

