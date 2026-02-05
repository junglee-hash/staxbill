CREATE FUNCTION [dbo].[CustomerExportCSVContact]
(	
	@FusebillId as bigint,
	@TimezoneId as int
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
	ISNULL(title.Name,'') as [Title]
	,ISNULL(c.MiddleName, '') as [Middle Name]
	,ISNULL(c.Suffix, '') as [Suffix]
	,convert(datetime,dbo.fn_GetTimezoneTime(c.ModifiedTimestamp, @TimezoneId)) as [Modified Timestamp]
	,ISNULL(CONVERT(varchar(20),convert(datetime,dbo.fn_GetTimezoneTime(c.ActivationTimestamp, @TimezoneId)), 120), '') as [Activation Timestamp]
	,ISNULL(CONVERT(varchar(20),convert(datetime,dbo.fn_GetTimezoneTime(c.CancellationTimestamp, @TimezoneId)), 120), '') as [Cancellation Timestamp]
	,ISNULL(cred.Username, '') as [Portal User Name]
	,CASE WHEN(cred.Password IS NULL) THEN 'false' ELSE 'true' END as [Portal Password Set]
	,customerAccountStatus.Name as [Accounting Status]
	,c.ArBalance as [AR Balance]
	,currency.IsoName as [Currency]
	,convert(datetime,dbo.fn_GetTimezoneTime(c.EffectiveTimestamp, @TimezoneId )) as [Created Timestamp] 
	,ISNULL(c.PrimaryEmail, '') as [Primary Email]
	,ISNULL(c.PrimaryPhone, '') as [Primary Phone]
	,ISNULL(c.SecondaryEmail, '') as [Secondary Email]
	,ISNULL(c.SecondaryPhone, '') as [Secondary Phone]
	,CASE WHEN afc.MrrDisplayTypeId = 1 THEN c.MonthlyRecurringRevenue ELSE c.CurrentMrr END as [Monthly Recurring Revenue]
	,CASE WHEN afc.MrrDisplayTypeId = 1 THEN c.NetMRR ELSE c.CurrentNetMrr END AS [Net MRR]
	,CASE WHEN exists(select 1 from dbo.Customer pCust where pCust.ParentId = c.id) THEN 'true' ELSE 'false' END AS [Customer Is A Parent]


	FROM
	Customer c
	INNER JOIN Lookup.CustomerAccountStatus customerAccountStatus ON c.AccountStatusId = CustomerAccountStatus.Id 
	LEFT JOIN dbo.CustomerCredential cred on c.Id = cred.Id
	LEFT JOIN Lookup.Title title on c.TitleId = title.Id
	INNER Join Lookup.Currency currency on c.CurrencyId = currency.Id
	INNER JOIN AccountFeatureConfiguration afc on afc.Id = c.AccountId	
 
	WHERE c.Id = @FusebillId
)

GO

