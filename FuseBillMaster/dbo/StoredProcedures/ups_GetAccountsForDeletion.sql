CREATE   PROCEDURE [dbo].[ups_GetAccountsForDeletion]
AS
BEGIN
	SET NOCOUNT ON;

    ;with UserMostRecentLogin as (
		select AccountId, max(CreatedTimestamp) as CreatedTimestamp
		from AuditTrail
		where CategoryId = 7
		group by AccountId
	)
	,StandardSandboxAccounts as (
			select 
				a.Id
				,ull.CreatedTimestamp as LastUserLogin
				,a.ShutdownReason
				,a.ShutdownDate
			from Account a
			left join UserMostRecentLogin ull on ull.AccountId = a.Id
			where 
				(
					a.TypeId = 1 
					or a.TypeId = 3
				)
				and a.DeletedTimestamp < DATEADD(DAY, -60, GETUTCDATE()) 
				and (
						ull.CreatedTimestamp < DATEADD(DAY, -30, GETUTCDATE())
						or ull.CreatedTimestamp is null
					)
		)
	, TrialTestDriveAccounts as (
		select 
				a.Id
				,ull.CreatedTimestamp as LastUserLogin
				,a.ShutdownReason
				,a.ShutdownDate
		from Account a
		left join UserMostRecentLogin ull on ull.AccountId = a.Id
		where 
			(
				a.TypeId = 2 
				or a.TypeId = 4
			)
			and (
					ull.CreatedTimestamp < DATEADD(MONTH, -1, GETUTCDATE())
					or ull.CreatedTimestamp is null
				)
	)
	, ValidAccounts as (
		select * from StandardSandboxAccounts
		union 
		select * from TrialTestDriveAccounts
	)
	select
		a.Id
		,a.CompanyName
		,a.ContactEmail
		,va.ShutdownDate
		,va.ShutdownReason
		,va.LastUserLogin
		,ap.[Data Weight]
	from ValidAccounts va
	join [Reporting].AccountProfile ap on ap.[Account ID] = va.Id
	join Account a on a.Id = va.Id
	where a.Id <> 10115
	order by ap.[Data Weight] desc
END

GO

