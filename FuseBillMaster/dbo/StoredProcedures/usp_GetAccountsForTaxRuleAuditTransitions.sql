CREATE   PROC [dbo].[usp_GetAccountsForTaxRuleAuditTransitions]
	@UTCDate datetime
AS
SET NOCOUNT ON

Select distinct
	ac.Id 
from
	Account ac
	inner join [dbo].[AccountFeatureConfiguration] as afc on afc.Id = ac.Id
	inner join [dbo].[TaxRule] as tr on tr.AccountId = ac.Id
where
	afc.TaxOptionId = 2
	and tr.IsRetired = 0
	and
	(
		(
			tr.AuditStatusId = 2
			and tr.EndDate <= @UTCDate
			and tr.EndDate is not null
		)
		or
		(
			tr.AuditStatusId = 1
			and tr.StartDate <= @UTCDate
			and tr.StartDate is not null
		)
	)
	and ac.IncludeInAutomatedProcesses = 1



SET NOCOUNT OFF

GO

