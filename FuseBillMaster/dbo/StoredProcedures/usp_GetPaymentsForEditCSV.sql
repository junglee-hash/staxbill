CREATE   PROCEDURE usp_GetPaymentsForEditCSV
	@AccountId bigint 
	,@StartDate datetime
	,@EndDate datetime 
	,@IncludeCheck bit
	,@IncludeDirectDeposit bit
	,@IncludeCreditCard bit 
	,@IncludeCash bit
	,@IncludeAch bit 
	,@IncludePaypal bit
	,@SettlementStatusSet bit
	,@SettlementStatus int
AS
BEGIN
	SET NOCOUNT ON;

	select 
	paj.Id as [PaymentActivityId]
	,paj.CustomerId as [StaxBillId]
	,c.Reference as [CustomerId]
	,paj.CreatedTimestamp as [CreatedDate]
	,paj.Amount as [PaymentAmount]
	,paj.ReconciliationId as [ReconciliationId]
	,paj.AuthorizationCode
	,p.Reference as [PaymentReference]
	,null as [TargetPaymentReference]
	,p.ReferenceDate as [PaymentReferenceDate]
	,null as [TargetPaymentReferenceDate]
	,case 
		when paj.SettlementStatusId = 1 then ''
		when paj.SettlementStatusId = 2 then 'Pending' 
		when paj.SettlementStatusId = 3 then 'Successful'
		when paj.SettlementStatusId = 4 then 'Failed'
	end as [SettlementStatus]
	,null as [TargetSettlementStatus]
	,paj.SettlementStatusMessage 
	,null as [TargetSettlementStatusMessage]
	from [PaymentActivityJournal] paj
	join Payment p on p.PaymentActivityJournalId = paj.Id
	join Customer c on paj.CustomerId = c.Id
	where paj.AccountId = @AccountId
	and (
			(@IncludeCheck = 1 and paj.PaymentMethodTypeId = 1)
			or (@IncludeDirectDeposit = 1 and paj.PaymentMethodTypeId = 2)
			or (@IncludeCreditCard = 1 and paj.PaymentMethodTypeId = 3)
			or (@IncludeCash = 1 and paj.PaymentMethodTypeId = 4)
			or (@IncludeAch = 1 and paj.PaymentMethodTypeId = 5)
			or (@IncludePaypal = 1 and paj.PaymentMethodTypeId = 6)
		)
	and (@SettlementStatusSet = 0 or paj.SettlementStatusId = @SettlementStatus)
	and paj.EffectiveTimestamp >= @StartDate
	and paj.EffectiveTimestamp <= @EndDate
END

GO

