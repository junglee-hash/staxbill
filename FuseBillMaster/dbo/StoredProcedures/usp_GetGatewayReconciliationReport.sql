CREATE PROCEDURE [dbo].[usp_GetGatewayReconciliationReport]
	@AccountId bigint
	,@StartDate datetime
	,@EndDate datetime
	,@GatewayType varchar(1000)
AS
BEGIN
	SET NOCOUNT ON;


	
	declare @GatewayTypes Table
	(
		GatewayId bigint
	)
	insert into @GatewayTypes
	select Data from dbo.Split(@GatewayType,',')

	--populate temp table with the values I need
	declare @PajTempTable Table(
		[PajId] bigint,
		[TransactionType] varchar(255),
		[PaymentActivityStatusId] int default 0,  -- 1 success, 2 failed, 3 unknown
		[AttemptNumber] int default 0,
		[SettlementStatustId] int default 0, --Unknown, Pending, Successful, Failed
		[PaymentMethodTypeId] int default 0,
		[PaymentMethodId] int default 0
	)
	INSERT INTO @PajTempTable ([PajId], [TransactionType], [PaymentActivityStatusId],[AttemptNumber], [SettlementStatustId],[PaymentMethodTypeId],[PaymentMethodId]) 
	Select 
        paj.Id as [PajId],
		pt.Name as [TransactionType],
		paj.PaymentActivityStatusId as [PaymentActivityStatusId],  -- 1 success, 2 failed, 3 unknown
		paj.AttemptNumber as [AttemptNumber],
		paj.SettlementStatusId as [SettlementStatusId],--Unknown, Pending, Successful, Failed
		paj.PaymentMethodTypeId AS [PaymentMethodTypeId],
		paj.PaymentMethodId as [PaymentMethodId]
	from [dbo].[PaymentActivityJournal] paj
	inner join Customer cust on cust.Id = paj.CustomerId
	inner join Account acc on acc.Id = cust.AccountId
	inner join [Lookup].[PaymentType] pt on pt.Id = paj.PaymentTypeId
	inner join @GatewayTypes gatewayTypes on gatewayTypes.GatewayId = paj.GatewayId
	where @AccountId = acc.Id
	and paj.EffectiveTimestamp >= @StartDate
	and paj.EffectiveTimestamp < @EndDate

	declare @ResultsTransactionType Table
	(
		[Key] varchar(255) not null, 
		Attempts int default 0 not null, 
		SuccessOnFirstAttempt int default 0 not null,
		SuccessOnRetryAttempts int default 0 not null,
		FailureOnFirstAttempt int default 0 not null,
		FailureOnRetryAttempts int default 0 not null,
		PendingSettlements int default 0 not null,
		Unknown int default 0 not null
	)
	declare @ResultsPaymentMethodType Table
	(
		[Key] varchar(255) not null, 
		Attempts int default 0 not null, 
		SuccessOnFirstAttempt int default 0 not null,
		SuccessOnRetryAttempts int default 0 not null,
		FailureOnFirstAttempt int default 0 not null,
		FailureOnRetryAttempts int default 0 not null,
		PendingSettlements int default 0 not null,
		Unknown int default 0 not null
	)
	--Insert the validation record


	Insert into @ResultsTransactionType ([Key], Attempts,SuccessOnFirstAttempt, SuccessOnRetryAttempts, FailureOnFirstAttempt, FailureOnRetryAttempts,PendingSettlements,  Unknown) 
	Select 
		'Validate' as [Key],
		Count(ptt.TransactionType)	as Attempts,
		isNull(SUM(
			Case
				when ptt.PaymentActivityStatusId = 1 and ptt.AttemptNumber = 0
				then 1
				else 0
			end
		), 0) as [SuccessOnFirstAttempt],
		isNull(SUM(
			Case
				when ptt.PaymentActivityStatusId = 1 and ptt.AttemptNumber > 0
				then 1
				else 0
			end
		), 0) as [SuccessOnRetryAttempts],
		isNull(SUM(
			Case
				when ptt.PaymentActivityStatusId = 2 and ptt.AttemptNumber = 0
				then 1
				else 0
			end
		), 0) as [FailureOnFirstAttempt],
		isNull(SUM(
			Case
				when ptt.PaymentActivityStatusId = 2 and ptt.AttemptNumber > 0
				then 1
				else 0
			end
		), 0) as [FailureOnRetryAttempts],
		isNull(SUM(
			Case
				when ptt.SettlementStatustId = 2
				then 1
				else 0
			end
		), 0) as [PendingSettlements],
		isNull(SUM(
			Case
				when ptt.PaymentActivityStatusId = 3
				then 1
				else 0
			end
		), 0) as [Unknown]
	
	from @PajTempTable ptt
	where ptt.TransactionType = 'Validate'

	--Insert the payment record
	

	Insert into @ResultsTransactionType ([Key], Attempts,SuccessOnFirstAttempt, SuccessOnRetryAttempts, FailureOnFirstAttempt, FailureOnRetryAttempts,PendingSettlements,  Unknown) 
	Select 
		'Payment' as [Key],
		Count(ptt.TransactionType)	as Attempts,
		isNull(SUM(
			Case
				-- not failed and not unknown
				when ptt.PaymentActivityStatusId != 2 AND ptt.PaymentActivityStatusId != 3 and ptt.AttemptNumber = 0 and (ptt.SettlementStatustId = 1 or ptt.SettlementStatustId = 3)
				then 1
				else 0
			end
		), 0) as [SuccessOnFirstAttempt],
		isNull(SUM(
			Case
				-- not failed and not unknown
				when ptt.PaymentActivityStatusId != 2 AND ptt.PaymentActivityStatusId != 3 and ptt.AttemptNumber > 0 and (ptt.SettlementStatustId = 1 or ptt.SettlementStatustId = 3)
				then 1
				else 0
			end
		),0) as [SuccessOnRetryAttempts],
		isNull(SUM(
			Case
				when ptt.AttemptNumber = 0 and ((ptt.PaymentActivityStatusId = 2 and ptt.SettlementStatustId = 1) or ptt.SettlementStatustId = 4)
				then 1
				else 0
			end
		),0) as [FailureOnFirstAttempt],
		isNull(SUM(
			Case
				when ptt.AttemptNumber > 0 and ((ptt.PaymentActivityStatusId = 2 and ptt.SettlementStatustId = 1) or ptt.SettlementStatustId = 4)
				then 1
				else 0
			end
		),0) as [FailureOnRetryAttempts],
		isNull(SUM(
			Case
				when ptt.SettlementStatustId = 2
				then 1
				else 0
			end
		),0) as [PendingSettlements],
		isNull(SUM(
			Case
				when ptt.PaymentActivityStatusId = 3
				then 1
				else 0
			end
		),0) as [Unknown]
	
	from @PajTempTable ptt
	where ptt.TransactionType = 'Payment'
	and (ptt.[PaymentMethodTypeId] = 3 or ptt.[PaymentMethodTypeId] = 5 or ptt.[PaymentMethodTypeId] = 6)


	
	Insert into @ResultsTransactionType ([Key], Attempts,SuccessOnFirstAttempt, SuccessOnRetryAttempts, FailureOnFirstAttempt, FailureOnRetryAttempts,PendingSettlements,  Unknown) 
	Select 
		'Refunds' as [Key],
		Count(ptt.TransactionType)	as Attempts,
		isNull(SUM(
			Case
				when ptt.PaymentActivityStatusId = 1 and ptt.AttemptNumber = 0 and (ptt.SettlementStatustId = 1 or ptt.SettlementStatustId = 3)
				then 1
				else 0
			end
		), 0) as [SuccessOnFirstAttempt],
		isNull(SUM(
			Case
				when ptt.PaymentActivityStatusId = 1 and ptt.AttemptNumber > 0 and (ptt.SettlementStatustId = 1 or ptt.SettlementStatustId = 3)
				then 1
				else 0
			end
		),0) as [SuccessOnRetryAttempts],
		isNull(SUM(
			Case
				when ptt.AttemptNumber = 0 and ((ptt.PaymentActivityStatusId = 2 and ptt.SettlementStatustId = 1) or ptt.SettlementStatustId = 4)
				then 1
				else 0
			end
		),0) as [FailureOnFirstAttempt],
		isNull(SUM(
			Case
				when  ptt.AttemptNumber > 0 and ((ptt.PaymentActivityStatusId = 2 and ptt.SettlementStatustId = 1) or ptt.SettlementStatustId = 4)
				then 1
				else 0
			end
		),0) as [FailureOnRetryAttempts],
		isNull(SUM(
			Case
				when ptt.SettlementStatustId = 2
				then 1
				else 0
			end
		),0) as [PendingSettlements],
		isNull(SUM(
			Case
				when ptt.PaymentActivityStatusId = 3
				then 1
				else 0
			end
		),0) as [Unknown]
	
	from @PajTempTable ptt
		left join Refund ref on ref.PaymentActivityJournalId = ptt.PajId
		left join [Transaction] trans on trans.Id = ref.Id 
	where ptt.TransactionType = 'Full Refund' 
		and ptt.[PaymentMethodTypeId] in (3,5,6)
		and (trans.TransactionTypeId in (4, 5)  -- partial or full refund
			OR ref.Id IS NULL) -- Unknown payments


	select * from @ResultsTransactionType

	--insert payment by type records

	Select
		ISNULL(pm.AccountType, 'Other') as [Key], 
		Count(ptt.TransactionType)	as Attempts,
		isNull(SUM(
			Case
				-- not failed and not unknown
				when ptt.PaymentActivityStatusId != 2 AND ptt.PaymentActivityStatusId != 3 and ptt.AttemptNumber = 0 and (ptt.SettlementStatustId = 1 or ptt.SettlementStatustId = 3)
				then 1
				else 0
			end
		), 0) as [SuccessOnFirstAttempt],
		isNull(SUM(
			Case
				-- not failed and not unknown
				when ptt.PaymentActivityStatusId != 2 AND ptt.PaymentActivityStatusId != 3 and ptt.AttemptNumber > 0 and (ptt.SettlementStatustId = 1 or ptt.SettlementStatustId = 3)
				then 1
				else 0
			end
		), 0) as [SuccessOnRetryAttempts],
		isNull(SUM(
			Case
				when ptt.AttemptNumber = 0 and ((ptt.PaymentActivityStatusId = 2 and ptt.SettlementStatustId = 1) or ptt.SettlementStatustId = 4)
				then 1
				else 0
			end
		), 0) as [FailureOnFirstAttempt],
		isNull(SUM(
			Case
				when ptt.AttemptNumber > 0 and ((ptt.PaymentActivityStatusId = 2 and ptt.SettlementStatustId = 1) or ptt.SettlementStatustId = 4)
				then 1
				else 0
			end
		), 0) as [FailureOnRetryAttempts],
		isNull(SUM(
			Case
				when ptt.SettlementStatustId = 2
				then 1
				else 0
			end
		), 0) as [PendingSettlements],
		isNull(SUM(
			Case
				when ptt.PaymentActivityStatusId = 3
				then 1
				else 0
			end
		), 0) as [Unknown]
	from @PajTempTable ptt --PajWithTypes ptt
	left join PaymentMethod pm ON pm.Id = ptt.PaymentMethodId
	group by pm.AccountType --ptt.[Key]
	order by CASE WHEN pm.AccountType IS NULL THEN 1 ELSE 0 END, pm.AccountType

END

GO

