CREATE PROCEDURE [dbo].[usp_GatewayReconciliationReportCSV]
	@AccountId bigint
	,@StartDate datetime
	,@EndDate datetime
	,@GatewayType varchar(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @GatewayTypes Table
	(
		GatewayId bigint
	)
	insert into @GatewayTypes
	select Data from dbo.Split(@GatewayType,',')

	declare @TimezoneId int

	select @TimezoneId = TimezoneId
	from AccountPreference where Id = @AccountId 

	--Temp table to customer details
	SELECT * INTO #CustomerData
	FROM BasicCustomerDataByAccount(@AccountId)

	SELECT 
		Customer.*
		, Data.Id as [Payment Activity ID]
		,(Case pt.Id
			when 3 -- when the type is Full Refund
			then 'Refund'
			else pt.Name
		end) as [Transaction Type]
		, [Transaction ID]
		, [Associated Transaction ID]
		, ps.Name as [Payment Source]
		, pmt.Name as [Payment Method Type]
		, ISNULL(pm.AccountType, 'Other') as [Payment Method]
		, dbo.fn_GetTimezoneTime(EffectiveTimestamp, @TimezoneId) as [Created Date]
		, dbo.fn_GetTimezoneTime(Data.ModifiedTimestamp, @TimezoneId) as [Last Modified Date]
		, Data.Amount
		, Data.GatewayFee as [Gateway Fee]
		, cur.IsoName as [Currency]
		, pas.Name as [Result]
		, Data.AttemptNumber as [Retry Count]
		, Data.GatewayName as [Gateway]
		, Data.AuthorizationCode as [Gateway Ref 1]
		, Data.SecondaryTransactionNumber as [Gateway Ref 2]
		, Data.AuthorizationResponse as [Gateway Response]
		, Data.ReconciliationId as [Reconciliation ID]
		, ss.Name as [Settlement Status]
		, Data.SettlementStatusMessage as [Settlement Response]
		, dbo.fn_GetTimezoneTime(Data.SettlementStatusLastCheckedTimestamp, @TimezoneId) as [Settlement Last Check Date]
		, dbo.fn_GetTimezoneTime(Data.SettlementStatusNextCheckTimestamp, @TimezoneId) as [Settlement Next Check Date]
		, dbo.fn_GetTimezoneTime(Data.SettlementStatusModifiedTimestamp, @TimezoneId) as [Settlement Date]
	FROM (
		Select 
			paj.*
			, COALESCE(p.Id, r.Id) as [Transaction ID]
			, r.OriginalPaymentId as [Associated Transaction ID]
		from [dbo].[PaymentActivityJournal] paj
		left join [Payment] p ON paj.Id = p.PaymentActivityJournalId
		left join [Refund] r ON paj.Id = r.PaymentActivityJournalId
		inner join Customer cust on cust.Id = paj.CustomerId
		inner join @GatewayTypes gatewayTypes on gatewayTypes.GatewayId = paj.GatewayId
		where @AccountId = cust.AccountId
		and paj.EffectiveTimestamp >= @StartDate
		and paj.EffectiveTimestamp < @EndDate
	) Data
	inner join [Lookup].[PaymentType] pt on pt.Id = Data.PaymentTypeId
	inner join [Lookup].[PaymentSource] ps ON ps.Id = Data.PaymentSourceId
	inner join [Lookup].[PaymentMethodType] pmt on pmt.Id = Data.PaymentMethodTypeId
	left join [PaymentMethod] pm ON pm.Id = Data.PaymentMethodId
	inner join [Lookup].[Currency] cur ON cur.Id = Data.CurrencyId
	inner join [Lookup].[PaymentActivityStatus] pas ON pas.Id = Data.PaymentActivityStatusId
	inner join [Lookup].[SettlementStatus] as ss ON ss.Id = Data.SettlementStatusId
	INNER JOIN #CustomerData as Customer ON Customer.[Fusebill ID] = Data.CustomerId
	ORDER BY Data.EffectiveTimestamp


	------------------------------------
	DROP TABLE #CustomerData
	------------------------------------

END

GO

