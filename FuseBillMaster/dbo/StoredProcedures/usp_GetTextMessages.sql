

CREATE procedure [dbo].[usp_GetTextMessages]

@AccountId bigint
AS
set transaction isolation level snapshot
set nocount on

SELECT TOP 100 ctl.Id
FROM CustomerTextLog ctl
INNER JOIN Customer c ON c.Id = ctl.CustomerId
WHERE c.AccountId = @AccountId
	AND ctl.TxtStatusId = 1
	AND ctl.SentTimestamp IS NULL
ORDER BY ctl.CreatedTimestamp ASC

SET NOCOUNT OFF

GO

