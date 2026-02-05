CREATE   Procedure [dbo].[usp_PostNewEarnings]
--DECLARE
       @ChargeId bigint = 0
       ,@UtcDateTime datetime --= '2019-10-06 14:05:00'
       ,@AccountId bigint --= 155886--155820 --(8 earnings)
       
AS


if @ChargeId = 0 
    set @ChargeId = null

if @ChargeId is not null and @AccountId is null
    select @AccountId = t.AccountId
    from [Transaction] t 
    where t.Id = @ChargeId

--Short-circuit if Account is excluded from Earning
IF EXISTS (
	SELECT 1
	FROM Account
	WHERE Id = @AccountId
	AND IncludeInAutomatedProcesses = 0
	AND ProcessEarningRegardless = 0
	)
	BEGIN
		Select 0 as CountOfEarnedRecords
	END

ELSE
	BEGIN
		if @UtcDateTime is null
			set @UtcDateTime = GETUTCDATE()

		Begin TRY

			set nocount on

			--Populate parameter to determine whether Earning records can be updated for AccountId
			DECLARE @EarningRecordPerMonth BIT

			SELECT @EarningRecordPerMonth = EarningRecordPerMonth 
			FROM dbo.AccountFeatureConfiguration
			WHERE Id = @AccountId

			DECLARE
				@AccountTimezoneDate DATE,
				@TimezoneId int,
				@AccountStartOfMonth DATE,
				@AccountEndOfMonth DATE,
				@PartialReverseChargeOptionId INT,
				@UtcDate DATETIME,
				@UtcStartOfMonth DATETIME,
				@UtcEndOfMonth DATETIME,
				@MissedEarning INT;

			SELECT
				@TimezoneId = ap.TimezoneId
			FROM
				AccountPreference ap
			WHERE
				ap.Id = @AccountId

			--SELECT @TimezoneId

			SELECT
				@AccountTimezoneDate = t.TimezoneDate
			FROM
				Timezone.tvf_GetTimezoneTime(@TimezoneId, @UtcDateTime) t

			SELECT
				@PartialReverseChargeOptionId = PartialReverseChargeOptionId
			FROM AccountAccountingPreference
			WHERE Id = @AccountId

			--SELECT @AccountTimezoneDate


			-- AccountPeriodStartOfDate == @AccountTimezoneDate (note for self as to what this variable holds)

			SET @AccountStartOfMonth = DATEADD(DAY, 1, EOMONTH(@AccountTimezoneDate, -1))
			SET @AccountEndOfMonth = EOMONTH(@AccountTimezoneDate)

			SELECT @UtcDate = t.UTCDateTime
			FROM Timezone.tvf_GetUTCTime(@TimezoneId, @AccountTimezoneDate,1,1) t

			SELECT @UtcStartOfMonth = t.UTCDateTime
			FROM Timezone.tvf_GetUTCTime(@TimezoneId, @AccountStartOfMonth,1,1) t

			SELECT @UtcEndOfMonth = t.UTCDateTime
			FROM Timezone.tvf_GetUTCTime(@TimezoneId, @AccountEndOfMonth,1,1) t

			--SELECT
			--	@UtcDateTime
			--	,@AccountTimezoneDate
			--	,@AccountStartOfMonth
			--	,@AccountEndOfMonth
			--	,@UtcDate
			--	,@UtcStartOfMonth
			--	,@UtcEndOfMonth


			Create table #EarningList
			(
				ChargeId bigint
				,OriginalChargeAmount money 
				,RemainingDeferredRevenue decimal(18,2)
				,TotalReversals decimal(18,2)
				,CustomerId bigint
				,AccountId bigint
				,CurrencyId bigint           
				,EarningStartDate datetime
				,EarningEndDate datetime
				,RelativeEarningTimestamp datetime
				,TotalPeriods int
				,PeriodsEarned int
				,RemainingEarningPeriods int
				,AmountToEarn decimal(18,2)
				,EarningTimingIntervalId int
				,EarningTimingTypeId int
				,NextEarningTimestamp datetime
				,PartialReverseChargeOption tinyint
				,UpdateTransactionId bigint null
				,AmountToEarnDay decimal(18,2)
				,DaysMissed int
				,ReversalSinceLastEarning bit
				,EarnPreReverseRate int
				,EarnPostReverseRate int
			)

			create table #TransactionResult
			(
				TransactionId bigint
				,CustomerId bigint
				,AccountId bigint
				,Amount money
				,ChargeId Bigint
				,EffectiveTimestamp datetime
				,CurrencyId bigint
				,NextEarningTimestamp datetime
				,EarningComplete bit
			)

			CREATE INDEX 
					[IX_#TransactionResult] 
					ON  #TransactionResult (TransactionId)

			CREATE TABLE #ChargesToEarn
			(
				ChargeId BIGINT
				,EarningStartDate DATETIME
				,EarningEndDate DATETIME
				,EarningStartDateAccountTimezone DATETIME NULL
				,EarningEndDateAccountTimezone DATETIME NULL
				,EarningTimingIntervalId INT
				,EarningTimingTypeId INT
				,EarningId BIGINT
				,DaysMissed INT
				,NextEarningTimestamp DATETIME
			)

			INSERT INTO #ChargesToEarn
			SELECT
				cle.Id as ChargeId
				,EarningStartDate
				,EarningEndDate
				,NULL AS EarningStartDateAccountTimezone
				,NULL AS EarningEndDateAccountTimezone
				,ch.EarningTimingIntervalId
				,ch.EarningTimingTypeId
				,cle.EarningId
				--Check to see if NextEarning was more than a day ago, indicates missed earning for a day
				,DATEDIFF(DAY,cle.NextEarningTimestamp,@UtcDate) as DaysMissed
				,cle.NextEarningTimestamp
			FROM ChargeLastEarning cle
			INNER JOIN Charge ch ON ch.Id = cle.Id
				AND ch.EarningTimingIntervalId NOT IN (3,7) --Does not earn, Milestone
				AND ch.EarningTimingTypeId != 3
				AND cle.EarningCompletedTimestamp is null
			INNER JOIN Invoice i ON i.Id = ch.InvoiceId
			INNER JOIN Customer c ON c.Id = i.CustomerId and c.StatusId <> 3
			CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, cle.NextEarningTimestamp) NextEarningTimestamp
			WHERE NextEarningTimestamp <= @UtcDate
			AND cle.AccountId = @AccountId
			AND i.AccountId = @AccountId

			--If one charge missed earning, have to assume all of them did
			SELECT @MissedEarning = MAX(DaysMissed)
			FROM #ChargesToEarn

			UPDATE cte
			SET EarningStartDateAccountTimezone = esd.TimezoneDate
				,EarningEndDateAccountTimezone = eed.TimezoneDate
			FROM #ChargesToEarn cte
			CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, cte.EarningStartDate ) esd
			CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, cte.EarningEndDate ) eed

			;with 
				EarnedRevenue as
				(
				select
					e.ChargeId 
					,sum(t.Amount ) as EarnedRevenue
				from 
					Earning e  with (readpast)
					INNER JOIN #ChargesToEarn cte ON cte.ChargeId = e.ChargeId
					inner join [Transaction] t  with (readpast) on T.Id = e.Id
				WHERE t.AccountId = @AccountId
				AND t.TransactionTypeId = 6
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
					INNER JOIN #ChargesToEarn cte ON cte.ChargeId = rc.OriginalChargeId
					inner join ReverseEarning  re  with (readpast) on rc.Id = re.ReverseChargeId
					inner join [Transaction] t  with (readpast) on re.Id = t.Id
				where t.AccountId = @AccountId 
				union all

				select
					rc.OriginalChargeId
					,t.Amount  as ReversedEarnedRevenue
				from 
					ReverseCharge rc  with (readpast)
					INNER JOIN #ChargesToEarn cte ON cte.ChargeId = rc.OriginalChargeId
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
					,MAX(t.EffectiveTimestamp) as LastReversalTimestamp
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
				,OriginalChargeAmount --money 
				,RemainingDeferredRevenue-- decimal(10,2)
				,TotalReversals
				,CustomerId --bigint
				,AccountId --bigint
				,CurrencyId --bigint           
				,EarningStartDate --datetime
				,EarningEndDate --datetime
				,RelativeEarningTimestamp 
				,EarningTimingIntervalId --int
				,EarningTimingTypeId --int
				,PartialReverseChargeOption
				,DaysMissed
				,ReversalSinceLastEarning
				,EarnPreReverseRate
				,EarnPostReverseRate
			)
			/************************************Charges due for new Earning Records*****************************************/
			Select 
				t.Id  as ChargeId
				,t.Amount as OriginalChargeAmount
				,t.Amount - isnull(rc.Amount,0) - isnull(er.EarnedRevenue ,0) +isnull(rr.ReversedEarnedRevenue ,0) as RemainingDeferredRevenue
				,isnull(rc.Amount,0) as TotalReversal
				,t.CustomerId as Customerid
				,t.AccountId
				,t.CurrencyId 
				,EarningStartDateAccountTimezone
				,EarningEndDateAccountTimezone
				,@AccountTimezoneDate 
				,cle.EarningTimingIntervalId 
				,cle.EarningTimingTypeId 
				,@PartialReverseChargeOptionId
				,DaysMissed
				,CASE WHEN ISNULL(DATEDIFF(MINUTE,cle.NextEarningTimestamp,rc.LastReversalTimestamp),0) > 0 THEN 1 ELSE 0 END as ReversalSinceLastEarning
				--this is more of an estimate, do not want to add more timezone conversions for performance considerations
				--it is only needed for when earning does not succeed for at least a full day, which is very rare
				,CASE WHEN CONVERT(DATE,rc.LastReversalTimestamp) = CONVERT(DATE,@UtcDateTime) THEN 1 ELSE 0 END as EarnPreReverseRate
				,CASE WHEN CONVERT(DATE,rc.LastReversalTimestamp) = CONVERT(DATE,@UtcDateTime) THEN 0 ELSE 1 END as EarnPostReverseRate
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
				and t.Id = isnull(@ChargeId,t.Id)
				and t.Amount - isnull(rc.Amount,0) - isnull(er.EarnedRevenue ,0) +isnull(rr.ReversedEarnedRevenue ,0) >0
			 OPTION (RECOMPILE)
			;

			--If AccountId is configured to update Earning records then find transaction id for update
			IF @EarningRecordPerMonth = 1
			BEGIN	
  				UPDATE el
  				SET UpdateTransactionId = t.Id
  				FROM #EarningList el
  				INNER JOIN ChargeLastEarning cle ON cle.Id = el.ChargeId
  				INNER JOIN [Transaction] t ON t.Id = cle.EarningId
  				WHERE t.AccountId = el.AccountId
  				AND t.CurrencyId = el.CurrencyId
  				AND t.EffectiveTimestamp >= @UtcStartOfMonth
  				AND t.EffectiveTimestamp < @UtcEndOfMonth
			END	

			Update el
			SET 
					PeriodsEarned = datediff(day,EarningStartDate, RelativeEarningTimestamp)
					,TotalPeriods = datediff(day,EarningStartDate, EarningEndDate)
					,NextEarningTimestamp = NextEarningTimestamp.UTCDateTime 
			from 
					#EarningList el
					OUTER APPLY Timezone.tvf_GetUTCTime(@TimezoneId, dateadd(day, -(datediff(day, RelativeEarningTimestamp, EarningEndDate) -1), EarningEndDate), DEFAULT, DEFAULT) as NextEarningTimestamp
			WHERE
					el.EarningTimingIntervalId = 1


			Update el
			SET 
					PeriodsEarned = datediff(month,EarningStartDate, RelativeEarningTimestamp)
					,TotalPeriods = datediff(month,EarningStartDate, EarningEndDate)
					,NextEarningTimestamp = NextEarningTimestamp.UTCDateTime 
			from 
					#EarningList el
					OUTER APPLY Timezone.tvf_GetUTCTime(@TimezoneId, dateadd(month, -(datediff(month, RelativeEarningTimestamp, EarningEndDate)-1), EarningEndDate), DEFAULT, DEFAULT) as NextEarningTimestamp
			WHERE
					el.EarningTimingIntervalId = 4

			Update el
			SET 
					PeriodsEarned = datediff(year,EarningStartDate,RelativeEarningTimestamp)
					,TotalPeriods = datediff(year,EarningStartDate , EarningEndDate)
					,NextEarningTimestamp = NextEarningTimestamp.UTCDateTime 
			from 
					#EarningList el
					OUTER APPLY Timezone.tvf_GetUTCTime(@TimezoneId, dateadd(year, -(datediff(year, RelativeEarningTimestamp, EarningEndDate)-1), EarningEndDate), DEFAULT, DEFAULT) as NextEarningTimestamp
			WHERE
					el.EarningTimingIntervalId = 5
			;

			Update el
			SET 
					PeriodsEarned = 0
					,TotalPeriods = 1
					,NextEarningTimestamp = null
			from 
					#EarningList el
			WHERE
					el.EarningTimingIntervalId = 6
			;


			Update #EarningList 
			SET
					RemainingEarningPeriods = TotalPeriods - PeriodsEarned - case when EarningTimingTypeId = 1 then  1   else 0 end
			;

			Update #EarningList 
			SET
					RemainingEarningPeriods = case when RemainingEarningPeriods < 0 then 0 else RemainingEarningPeriods end
					, TotalPeriods = case when TotalPeriods < 1 then 1 else TotalPeriods end
			;


			Update #EarningList 
			SET 
					AmountToEarn =
					CASE WHEN PartialReverseChargeOption = 1 THEN
						round(OriginalChargeAmount * (TotalPeriods - RemainingEarningPeriods) / TotalPeriods, 2) - (OriginalChargeAmount  - RemainingDeferredRevenue  )
					--Try to catch up daily earning
					WHEN PartialReverseChargeOption = 2 AND EarningTimingIntervalId = 1 AND (@MissedEarning >= 1 OR ReversalSinceLastEarning = 1) THEN
						CASE WHEN TotalReversals = 0 THEN
							round(OriginalChargeAmount * (TotalPeriods - RemainingEarningPeriods) / TotalPeriods, 2) - (OriginalChargeAmount  - RemainingDeferredRevenue  )
						WHEN ReversalSinceLastEarning = 1 THEN
							--earn the pre-reversal amount for missed days plus today at post reversal amount
							round(OriginalChargeAmount / TotalPeriods, 2) * (DaysMissed + EarnPreReverseRate) + round(RemainingDeferredRevenue / (TotalPeriods - PeriodsEarned) ,2) * EarnPostReverseRate
						WHEN DaysMissed = 1 THEN
							--Earn the post-reversal amount, ideally we could use this to handle multiple days missed but right now it ends up in over earning
							round(RemainingDeferredRevenue / (TotalPeriods - PeriodsEarned) ,2) * (DaysMissed + 1)
						ELSE 
							--Reversals and multiple days missed, just do the normal spread because it is super complicated
							round(RemainingDeferredRevenue / (TotalPeriods - PeriodsEarned) ,2)
						END
					ELSE
						CASE WHEN TotalPeriods - PeriodsEarned > 0 THEN 
							round(RemainingDeferredRevenue / (TotalPeriods - PeriodsEarned) ,2)
						ELSE round(RemainingDeferredRevenue, 2)
						END
					END
			;

			--Cap any negative earning but keep the data so we can update next earning timestamps
			Update #EarningList 
			SET 
					AmountToEarn  =  0 where AmountToEarn < 0
			;
			
			update #EarningList 
			set AmountToEarnDay = AmountToEarn;

			--Acrue Discounts for Charges that Earned Revenue
			Create table #DeferredDiscounts 
			(
					DiscountId bigint not null
					, ChargeId bigint not null
					, RemainingDiscountAmount decimal(18,2) not null
					, DaysRemaining int not null
					, AmountToAccrue decimal(18,2)
					, EffectiveTimestamp datetime not null
					, CurrencyId int not null
					, CustomerId bigint not null
					, AccountId bigint not null
					,UpdateTransactionId bigint null
			)

			Insert into #DeferredDiscounts 
			(
					DiscountId 
					, ChargeId 
					, RemainingDiscountAmount 
					, DaysRemaining 
					, AmountToAccrue 
					, EffectiveTimestamp 
					, CurrencyId 
					,CustomerId 
					,AccountId
			)
			Select
					d.Id as DiscountId
					, d.ChargeId as ChargeId
					, d.UnearnedAmount
					,el.RemainingEarningPeriods  
					,CASE WHEN el.AmountToEarn = el.RemainingDeferredRevenue THEN
						--Earning the last amount of revenue, earn the remainder of the discount
						d.UnearnedAmount
					ELSE
						--Calculate how much of the discount to earn
						CASE WHEN PartialReverseChargeOption = 1 THEN
							round(t.Amount *(TotalPeriods - RemainingEarningPeriods  ) /TotalPeriods,2)  - (t.Amount - d.UnearnedAmount )
						WHEN PartialReverseChargeOption = 2 AND EarningTimingIntervalId = 1 AND (@MissedEarning >= 1 OR ReversalSinceLastEarning = 1) THEN
							CASE WHEN TotalReversals = 0 THEN
								round(t.Amount *(TotalPeriods - RemainingEarningPeriods  ) /TotalPeriods,2)  - (t.Amount - d.UnearnedAmount )
							WHEN ReversalSinceLastEarning = 1 THEN
								--earn the pre-reversal amount for missed days plus today at post reversal amount
								round(t.Amount / TotalPeriods, 2) * (DaysMissed + EarnPreReverseRate) + round(d.UnearnedAmount / (TotalPeriods - PeriodsEarned),2) * EarnPostReverseRate
							WHEN DaysMissed = 1 THEN
								--Earn the post-reversal amount
								round(d.UnearnedAmount / (TotalPeriods - PeriodsEarned),2) * (DaysMissed + 1)
							ELSE
								round(d.UnearnedAmount / (TotalPeriods - PeriodsEarned),2)
							END
						ELSE
							CASE WHEN TotalPeriods - PeriodsEarned > 0 THEN 
								round(d.UnearnedAmount / (TotalPeriods - PeriodsEarned),2)
							ELSE round(d.UnearnedAmount,2)
							END
						END
					END as AmountToAccrue
					,@UtcDateTime 
					,el.CurrencyId 
					,el.CustomerId 
					,el.AccountId
			From 
					#EarningList el
					inner join Discount d  with (readpast)
					inner join [Transaction] t with (readpast) on d.Id = t.Id and t.TransactionTypeId = 21
						on el.ChargeId = d.ChargeId 

			--Can delete these as we do nothing for $0 discount accrual
			DELETE FROM #DeferredDiscounts
			WHERE AmountToAccrue <= 0

			IF @EarningRecordPerMonth = 1
			BEGIN
				UPDATE dd
				SET UpdateTransactionId = t.Id
				FROM #DeferredDiscounts dd
					CROSS APPLY (
						SELECT TOP 1 Id,DiscountId
						FROM EarningDiscount ed
						WHERE ed.DiscountId = dd.DiscountId
						ORDER BY Id DESC
						) mre
					INNER JOIN [Transaction] t ON t.Id = mre.Id
					CROSS APPLY Timezone.tvf_GetTimezoneTime(@TimezoneId, t.EffectiveTimestamp) EffectiveTimestamp
				WHERE t.AccountId = dd.AccountId
					AND t.CurrencyId = dd.CurrencyId
					AND EffectiveTimestamp.TimezoneDate >= @AccountStartOfMonth
					AND EffectiveTimestamp.TimezoneDate < @AccountEndOfMonth
			END

			Create table #DiscountTransactionResult
			(
				TransactionId bigint not null
				,DiscountId bigint not null
				,Amount money not null
				,RemainingDiscountAmount money not null
				,CustomerId bigint not null
				,AccountId bigint not null
				,CurrencyId int not null
				,EffectiveTimestamp datetime
			)

			declare @Count int = 0

			--Deal with $0 earning first
			--Do not want to make transactions but do need to update some earning info
			WHILE EXISTS (SELECT 1 FROM #EarningList WHERE AmountToEarn <= 0)
				BEGIN

					BEGIN TRANSACTION

					SELECT TOP 500
							GETUTCDATE()  as CreatedTimestamp
							,GETUTCDATE() as ModifiedTimestamp
							,CustomerId as CustomerId
							,AccountId
							,AmountToEarn  as Amount
							,@UtcDateTime   as EffectiveTimestamp
							,6 as TransactionTypeId
							,null as Description
							,CurrencyId as CurrencyId
							,ChargeId
							,nextEarningTimestamp
							,UpdateTransactionId
							,CASE WHEN RemainingDeferredRevenue = AmountToEarn THEN 1 ELSE 0 END as EarningComplete
						INTO #ZeroTransactionResult
						From
						#EarningList 
						WHERE AmountToEarn <= 0 

						Update 
							cle
					set 
							cle.ModifiedTimestamp = tr.EffectiveTimestamp 
							,cle.NextEarningTimestamp = tr.NextEarningTimestamp
							--Only change the completed timestamp if this earning run has determined the charge was complete, otherwise leave as is
							,cle.EarningCompletedTimestamp = CASE WHEN tr.EarningComplete = 1 THEN @UtcDateTime ELSE cle.EarningCompletedTimestamp END
					from
							ChargeLastEarning cle
							inner join #ZeroTransactionResult tr
							on cle.Id = tr.ChargeId 


					--We want to count the total across all instances of the loops
					set @Count = @Count + ISNULL((Select Count(*) from #TransactionResult ),0)

					--remove the charges we have earned from our initial list
					delete el 
					from #EarningList el
					inner join #ZeroTransactionResult tr ON tr.ChargeId = el.ChargeId

					--clear out loop variables for next iteration
					drop table #ZeroTransactionResult

					COMMIT TRANSACTION

			END



					--#EarningList has records deleted as the transactions are created each loop
					WHILE EXISTS (SELECT 1 FROM #EarningList)
				BEGIN

					BEGIN TRANSACTION

					--Merge statement is being used instead of an Insert because we need to match some source data that is not inserted to the output of the insert
					--and the output does not have enough information to match it to the source row that birthed it
					Merge  [Transaction] as Target
					Using
					(
					--Batch the inserts, this controls the amount of discounts as well
					SELECT TOP 500
							GETUTCDATE()  as CreatedTimestamp
							,GETUTCDATE() as ModifiedTimestamp
							,CustomerId as CustomerId
							,AccountId
							,AmountToEarn  as Amount
							,@UtcDateTime   as EffectiveTimestamp
							,6 as TransactionTypeId
							,null as Description
							,CurrencyId as CurrencyId
							,ChargeId
							,nextEarningTimestamp
							,UpdateTransactionId
							,CASE WHEN RemainingDeferredRevenue = AmountToEarn THEN 1 ELSE 0 END as EarningComplete
							From
							#EarningList 
					) as Source
					on target.Id = source.UpdateTransactionId
					WHEN MATCHED THEN UPDATE SET
						Target.Amount = Target.Amount + Source.Amount
						,Target.EffectiveTimestamp = Source.EffectiveTimestamp
						,Target.ModifiedTimestamp = Source.ModifiedTimestamp
					WHEN NOT MATCHED BY TARGET THEN 
					INSERT (AccountId, CreatedTimestamp, CustomerId, Amount, EffectiveTimestamp, TransactionTypeId, Description, CurrencyId, SortOrder, ModifiedTimestamp)  
					VALUES (Source.AccountId, GETUTCDATE(),Source.CustomerId,Source.Amount,Source.EffectiveTimestamp,Source.TransactionTypeId,Source.Description,Source.CurrencyId, 99, Source.ModifiedTimestamp)
					Output  
							INSERTED.Id
							, Inserted.CustomerId
							, Inserted.AccountId
							, Inserted.Amount
							, Inserted.EffectiveTimestamp
							, Source.ChargeId
							, inserted.CurrencyId
							,Source.NextEarningTimestamp
							,Source.EarningComplete
					into #TransactionResult  
					(
							TransactionId
							,CustomerId
							,AccountId
							,Amount
							,EffectiveTimestamp
							, ChargeId
							, CurrencyId
							,NextEarningTimestamp
							,EarningComplete
					)  
					;

					Merge Earning as Target
					Using
					(
					--Batch the inserts, this controls the amount of discounts as well
					SELECT
							TransactionId as Id
							,ChargeId as ChargeId
							,Null as Reference
					FROM 
							#TransactionResult 

					) as Source
					on target.Id = source.Id
					--WHEN MATCHED BY TARGET THEN do nothing
				WHEN NOT MATCHED BY TARGET THEN 
					INSERT (Id, ChargeId, Reference)
					VALUES (Id, ChargeId, Reference)
					;

					Update 
							cle
					set 
							EarningId = tr.TransactionId 
							,cle.ModifiedTimestamp = tr.EffectiveTimestamp 
							,cle.NextEarningTimestamp = tr.NextEarningTimestamp
							,cle.LastEarnedAmount = er.AmountToEarnDay
							--Only change the completed timestamp if this earning run has determined the charge was complete, otherwise leave as is
							,cle.EarningCompletedTimestamp = CASE WHEN tr.EarningComplete = 1 THEN @UtcDateTime ELSE cle.EarningCompletedTimestamp END
					from
							ChargeLastEarning cle
							inner join #TransactionResult tr on cle.Id = tr.ChargeId 
							inner join #EarningList er on er.ChargeId = cle.Id

					Merge  [Transaction] as Target
					Using
					(
							SELECT
							dd.CustomerId 
							,dd.AccountId
							,dd.AmountToAccrue 
							,dd.EffectiveTimestamp 
							,23 as TransactionTypeId
							,dd.DiscountId
							,dd.CurrencyId
							,dd.RemainingDiscountAmount
							,dd.UpdateTransactionId
					From 
							#DeferredDiscounts dd
					--Filter down to only the discounts related to the charges that were dealt with in the first step
					INNER JOIN
						#TransactionResult tr ON tr.ChargeId = dd.ChargeId
					) as Source
					on Target.Id = Source.UpdateTransactionId
					WHEN MATCHED THEN UPDATE SET
						Target.Amount = Target.Amount + Source.AmountToAccrue
						,Target.EffectiveTimestamp = Source.EffectiveTimestamp
						,Target.ModifiedTimestamp = GETUTCDATE()
					WHEN NOT MATCHED BY TARGET THEN 
					INSERT (AccountId, CreatedTimestamp, CustomerId, Amount, EffectiveTimestamp, TransactionTypeId, Description, CurrencyId, SortOrder, ModifiedTimestamp)  
					VALUES (AccountId, GETUTCDATE(),Source.CustomerId,Source.AmountToAccrue,Source.EffectiveTimestamp,Source.TransactionTypeId,NULL,Source.CurrencyId, 99, GETUTCDATE())
					Output  Inserted.Id as TransactionId
					, Source.DiscountId as DiscountId 
					,Source.AmountToAccrue as Amount
					, Source.RemainingDiscountAmount
					, Source.CustomerId
					, Source.AccountId
					, Source.CurrencyId
					, Source.EffectiveTimestamp
					into 
					#DiscountTransactionResult (
					TransactionId
					, DiscountId
					, Amount
					,RemainingDiscountAmount
					,CustomerId
					, AccountId
					,CurrencyId
					,EffectiveTimestamp
					)
					;

					MERGE EarningDiscount as Target
					Using
					(
					Select
							TransactionId as Id
							,DiscountId as ChargeId
							,Null as Reference
					from 
							#DiscountTransactionResult  
				)as Source on target.Id = source.Id
					--WHEN MATCHED BY TARGET THEN do nothing
				WHEN NOT MATCHED BY TARGET THEN 
					INSERT (Id, DiscountId, Reference)
					VALUES (Id, ChargeId, Reference)
					;

					Update D
					Set    
							UnearnedAmount = dtr.RemainingDiscountAmount   - dtr.Amount 
					From 
							Discount d
							inner join #DiscountTransactionResult dtr
							on d.Id = dtr.DiscountId 

          

					--We want to count the total across all instances of the loops
					set @Count = @Count + ISNULL((Select Count(*) from #TransactionResult ),0)

					--remove the charges we have earned from our initial list
					delete el 
					from #EarningList el
					inner join #TransactionResult tr ON tr.ChargeId = el.ChargeId

					--remove the discounts we have earned from our initial list
					delete dd
					from #DeferredDiscounts dd
					inner join #DiscountTransactionResult dtr ON dtr.DiscountId = dd.DiscountId

					--clear out loop variables for next iteration
					truncate table #TransactionResult
					truncate table #DiscountTransactionResult			  
              
			COMMIT TRANSACTION

			END

			set nocount off

			drop table #EarningList
			drop table #DeferredDiscounts
			drop table #TransactionResult
			drop table #DiscountTransactionResult
			drop table #ChargesToEarn

			Select @Count as CountOfEarnedRecords
		END TRY

		Begin Catch

			   IF XACT_STATE() <> 0  
					  Rollback Tran
			   DECLARE @ErrorMessage NVARCHAR(4000);
			   DECLARE @ErrorSeverity INT;
			   DECLARE @ErrorState INT;

			   SELECT 
					  @ErrorMessage = ERROR_MESSAGE(),
					  @ErrorSeverity = ERROR_SEVERITY(),
					  @ErrorState = ERROR_STATE();

			   RAISERROR 
			   (
					  @ErrorMessage, -- Message text.
					  @ErrorSeverity, -- Severity.
					  @ErrorState -- State.
			   );
		End Catch
	END --End of the AccountExcludingFromEarning If

GO

