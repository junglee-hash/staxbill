CREATE FUNCTION [dbo].[tvf_CustomerEffectiveStatuses]
(	
	@CustomerId BIGINT,
	@UTCEffectiveDateTime DATETIME
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT
	C.Id AS CustomerId
	,cas.JournalId_AccountStatus
	,cas.EffectiveTimestamp_AccountStatus
	,cas.AccountStatusId
	,cas.AccountStatus
	,cs.JournalId_CustomerStatus
	,cs.EffectiveTimestamp_CustomerStatus
	,cs.CustomerStatusId
	,cs.CustomerStatus
	FROM Customer c
	CROSS APPLY (
		SELECT TOP 1
			casj.Id AS JournalId_AccountStatus
			,casj.EffectiveTimestamp AS EffectiveTimestamp_AccountStatus
			,casj.StatusId AS AccountStatusId
			,lcas.[Name] AS AccountStatus
		FROM CustomerAccountStatusJournal casj
		INNER JOIN lookup.CustomerAccountStatus lcas ON casj.StatusId = lcas.Id
		WHERE casj.CustomerId = c.Id
		AND casj.EffectiveTimestamp < @UTCEffectiveDateTime
		ORDER BY SequenceNumber DESC
		) cas
	CROSS APPLY (
		SELECT TOP 1
			csj.Id AS JournalId_CustomerStatus
			,csj.EffectiveTimestamp AS EffectiveTimestamp_CustomerStatus
			,csj.StatusId AS CustomerStatusId
			,lcs.[Name] AS CustomerStatus
		FROM CustomerStatusJournal csj
		INNER JOIN lookup.CustomerStatus lcs ON csj.StatusId = lcs.Id
		WHERE csj.CustomerId = c.Id
		AND csj.EffectiveTimestamp < @UTCEffectiveDateTime
		ORDER BY SequenceNumber DESC
		) cs
	WHERE c.Id = @CustomerId
)

GO

