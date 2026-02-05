
CREATE PROCEDURE [dbo].[usp_GetUnearnedCharges]
	@subscriptionId AS bigint,
	@accountId AS bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
			Create table #EarningList
			(
				ChargeId bigint
				,InvoiceId bigint
				,OriginalChargeAmount money 
				,RemainingDeferredRevenue decimal(18,2)
				,TotalReversals decimal(18,2)
				,CustomerId bigint
				,AccountId bigint
				,CurrencyId bigint           
			)		

			CREATE TABLE #ChargesToEarn
			(
				ChargeId BIGINT
				,EarningStartDate DATETIME
				,EarningEndDate DATETIME
				,EarningTimingIntervalId INT
				,EarningTimingTypeId INT
				,EarningId BIGINT
				,InvoiceId BIGINT
			)

			INSERT INTO #ChargesToEarn
			SELECT 
				cle.Id as ChargeId
				,EarningStartDate
				,EarningEndDate
				,ch.EarningTimingIntervalId
				,ch.EarningTimingTypeId
				,cle.EarningId
				,ch.InvoiceId as InvoiceId
			FROM ChargeLastEarning cle
			INNER JOIN Charge ch ON ch.Id = cle.Id
				--We do not want to exclude Deposit charges from this, as we want to earn deposits on cancellation
				--So we are not going to exclude the deposit earning types
				--AND ch.EarningTimingIntervalId != 3
				--AND ch.EarningTimingTypeId != 3
				AND cle.EarningCompletedTimestamp is null
			Inner join SubscriptionProductCharge spc on ch.Id = spc.Id
			inner join SubscriptionProduct sp on sp.Id = spc.SubscriptionProductId and sp.SubscriptionId = @subscriptionId
			INNER JOIN Invoice i ON i.Id = ch.InvoiceId
			WHERE i.AccountId = @AccountId

			;with 
				EarnedRevenue as
				(
				select
					e.ChargeId 
					,sum(t.Amount ) as EarnedRevenue
				from 
					Earning e  with (readpast)
					inner join [Transaction] t  with (readpast) on T.Id = e.Id
				WHERE t.AccountId = @AccountId
				group by 
					e.ChargeId 
				),
					
				ReversedRevenue as
				(
				Select 
					OriginalChargeId 
					,sum(ReversedEarnedRevenue) as ReversedEarnedRevenue
				from
				(
				select
					rc.OriginalChargeId
					,t.Amount  as ReversedEarnedRevenue
				from 
					ReverseCharge rc  with (readpast)
					inner join ReverseEarning  re  with (readpast) on rc.Id = re.ReverseChargeId
					inner join [Transaction] t  with (readpast) on re.Id = t.Id
				where t.AccountId = @AccountId 
				union all

				select
					rc.OriginalChargeId
					,t.Amount  as ReversedEarnedRevenue
				from 
					ReverseCharge rc  with (readpast)
					inner join [Transaction] t  with (readpast) on rc.Id = t.Id and t.TransactionTypeId = 24
				where t.AccountId = @AccountId 
				)Data
				group by 
					OriginalChargeId 
				),
					
				ReversedCharges as
				(
				Select 
					rc.OriginalChargeId 
					,sum(t.Amount) as Amount
				from 
					ReverseCharge rc  with (readpast)
					inner join [Transaction] t  with (readpast) on rc.Id = t.Id
				where t.AccountId = @AccountId 
				Group by 
					rc.OriginalChargeId
				)

			Insert into #EarningList 
			(
				ChargeId-- bigint
				,InvoiceId
				,OriginalChargeAmount --money 
				,RemainingDeferredRevenue-- decimal(10,2)
				,TotalReversals
				,CustomerId --bigint
				,AccountId --bigint
				,CurrencyId --bigint           
			)
			/************************************Charges due for new Earning Records*****************************************/
			Select 
				t.Id as ChargeId
				,cle.InvoiceId as InvoiceId
				,t.Amount as OriginalChargeAmount
				,t.Amount - isnull(rc.Amount,0) - isnull(er.EarnedRevenue ,0) +isnull(rr.ReversedEarnedRevenue ,0) as RemainingDeferredRevenue
				,isnull(rc.Amount,0) as TotalReversal
				,t.CustomerId as Customerid
				,t.AccountId
				,t.CurrencyId 
			From
				#ChargesToEarn cle
				inner join [Transaction] t  with (readpast) ON cle.ChargeId = t.Id
				left join ReversedCharges rc 
				on cle.ChargeId = rc.OriginalChargeId 
				left join EarnedRevenue er
				on cle.ChargeId = er.ChargeId 
				left join ReversedRevenue rr
				on cle.ChargeId = rr.OriginalChargeId 
			Where 
				t.TransactionTypeId != 19
				and t.Amount - isnull(rc.Amount,0) - isnull(er.EarnedRevenue ,0) + isnull(rr.ReversedEarnedRevenue ,0) >0
			 OPTION (RECOMPILE)
			;

select ChargeId, InvoiceId from #EarningList

drop table #EarningList
drop table #ChargesToEarn

END

GO

