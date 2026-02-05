
CREATE PROCEDURE [dbo].[usp_CleanupAutomatedHistoryFailures]

AS

--Remove dunning failure history for customers that are now in good status
DELETE af
FROM AccountAutomatedHistoryFailure af
INNER JOIN Customer c ON c.Id = af.CustomerId
	AND c.AccountId = af.AccountId
WHERE c.AccountStatusId = 1
	AND af.AccountAutomatedHistoryTypeId = 5

GO

