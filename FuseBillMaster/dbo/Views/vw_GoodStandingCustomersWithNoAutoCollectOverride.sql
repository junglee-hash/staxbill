
CREATE VIEW [dbo].[vw_GoodStandingCustomersWithNoAutoCollectOverride]
AS
    SELECT c.Id, c.AccountId, c.ArBalance, c.AccountStatusId, c.StatusId, 
	cbs.CustomerGracePeriod, cbs.GracePeriodExtension, casj.EffectiveTimestamp as LastJournalTimestamp
    FROM     dbo.Customer AS c INNER JOIN
                      dbo.CustomerBillingSetting AS cbs ON c.Id = cbs.Id AND cbs.AutoCollect IS NULL
					  INNER JOIN dbo.CustomerAccountStatusJournal casj ON c.Id = casj.CustomerId AND casj.IsActive = 1
    WHERE  (c.AccountStatusId = 1)

GO

