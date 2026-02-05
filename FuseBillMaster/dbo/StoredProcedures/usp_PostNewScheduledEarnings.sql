CREATE   Procedure [dbo].[usp_PostNewScheduledEarnings]
--DECLARE
       @UtcDateTime datetime --= '2019-10-06 14:05:00'
       ,@AccountId bigint --= 155886--155820 --(8 earnings)
       
AS

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

			SELECT 
			   Id
			   ,StandardName
			   ,utcDate.UTCDateTime as UtcPeriodEndDateTime
		INTO #ModifiedEndTimestamp
		FROM Lookup.Timezone
		OUTER APPLY Timezone.tvf_GetTimezoneTime(Id, @UtcDateTime) t
		OUTER APPLY Timezone.tvf_GetUTCTime(Id, DATEADD(DAY, 1, t.TimezoneDate), DEFAULT, DEFAULT) utcDate


			Create table #EarningList
			(
				ChargeId bigint
				,CustomerId bigint
				,AccountId bigint
				,CurrencyId bigint           
				,AmountToEarn decimal(18,2)
				,PercentageToEarn decimal(18,2)
				,Reference nvarchar(500) NULL
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
				,EarningComplete bit
				,Reference nvarchar(500) NULL
			)

			CREATE INDEX 
					[IX_#TransactionResult] 
					ON  #TransactionResult (TransactionId)

			CREATE TABLE #ChargesToEarn
			(
				EarningScheduleId BIGINT
				,ChargeId BIGINT
				,AmountToEarn decimal(18,2)
				,Reference nvarchar(500) NULL
			)

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

			INSERT INTO #ChargesToEarn
			SELECT 
				es.Id
				,es.ChargeId
				, CASE WHEN es.EarningScheduleTypeId = 2 THEN
					t.Amount - isnull(rc.Amount,0) - isnull(er.EarnedRevenue ,0) +isnull(rr.ReversedEarnedRevenue ,0)
					ELSE es.ScheduledAmount END
				,es.Reference
			FROM EarningSchedule es
			INNER JOIN Charge ch ON ch.Id = es.ChargeId
			INNER JOIN [Transaction] t ON t.Id = ch.Id
			INNER JOIN Invoice i ON i.Id = ch.InvoiceId
			INNER JOIN Customer c ON c.Id = i.CustomerId and c.StatusId <> 3
			INNER JOIN AccountPreference ap on c.AccountId = ap.Id
			INNER JOIN #ModifiedEndTimestamp MED on ap.TimezoneId = MED.Id 
			LEFT JOIN ReversedCharges rc on es.ChargeId = rc.OriginalChargeId 
			LEFT JOIN EarnedRevenue er on es.ChargeId = er.ChargeId 
			LEFT JOIN ReversedRevenue rr on es.ChargeId = rr.OriginalChargeId 
			WHERE es.ScheduledTimestamp IS NOT NULL 
				AND es.ScheduledTimestamp <= MED.UtcPeriodEndDateTime
			AND i.AccountId = @AccountId

			Insert into #EarningList 
			(
				ChargeId-- bigint
				,CustomerId --bigint
				,AccountId --bigint
				,CurrencyId --bigint
				,AmountToEarn
				,PercentageToEarn
				,Reference
			)
			/************************************Charges due for new Earning Records*****************************************/
			Select 
				t.Id  as ChargeId
				,t.CustomerId as Customerid
				,t.AccountId
				,t.CurrencyId 
				,cle.AmountToEarn
				,cle.AmountToEarn / t.Amount
				,cle.Reference
			From
				#ChargesToEarn cle
				inner join [Transaction] t  with (readpast) ON cle.ChargeId = t.Id
			Where 
				t.TransactionTypeId != 19
			 OPTION (RECOMPILE)
			;

			
			--Acrue Discounts for Charges that Earned Revenue
			Create table #DeferredDiscounts 
			(
					DiscountId bigint not null
					, ChargeId bigint not null
					, EffectiveTimestamp datetime not null
					, CurrencyId int not null
					, CustomerId bigint not null
					, AccountId bigint not null
					, AmountToEarn decimal(18,2)
					,Reference nvarchar(500) NULL
			)

			Insert into #DeferredDiscounts 
			(
					DiscountId 
					, ChargeId 
					, EffectiveTimestamp 
					, CurrencyId 
					,CustomerId 
					,AccountId
					,AmountToEarn
					,Reference
			)
			Select
					d.Id as DiscountId
					, d.ChargeId as ChargeId
					,@UtcDateTime 
					,el.CurrencyId 
					,el.CustomerId 
					,el.AccountId
					,t.Amount * el.PercentageToEarn
					,el.Reference
			From 
					#EarningList el
					inner join Discount d  with (readpast)
					inner join [Transaction] t with (readpast) on d.Id = t.Id and t.TransactionTypeId = 21
						on el.ChargeId = d.ChargeId 

			update #DeferredDiscounts 
			set 
				AmountToEarn = 0 
			where 
				AmountToEarn < 0


			Create table #DiscountTransactionResult
			(
				TransactionId bigint not null
				,DiscountId bigint not null
				,Amount money not null
				,CustomerId bigint not null
				,AccountId bigint not null
				,CurrencyId int not null
				,EffectiveTimestamp datetime
				,Reference nvarchar(500) NULL
			)

			declare @Count int = 0

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
							,NULL as Description
							,CurrencyId as CurrencyId
							,ChargeId
							,Reference
							From
							#EarningList 
					) as Source
					on target.Id = 0 -- No grouped earning, so just use 0 to avoid bigger refactor from the existing earning sproc
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
							,Source.Reference
					into #TransactionResult  
					(
							TransactionId
							,CustomerId
							,AccountId
							,Amount
							,EffectiveTimestamp
							, ChargeId
							, CurrencyId
							,Reference
					)  
					;

					Merge Earning as Target
					Using
					(
					--Batch the inserts, this controls the amount of discounts as well
					SELECT
							TransactionId as Id
							,ChargeId as ChargeId
							,Reference as Reference
					FROM 
							#TransactionResult 

					) as Source
					on target.Id = source.Id
					--WHEN MATCHED BY TARGET THEN do nothing
				WHEN NOT MATCHED BY TARGET THEN 
					INSERT (Id, ChargeId, Reference)
					VALUES (Id, ChargeId, Reference)
					;

					Merge  [Transaction] as Target
					Using
					(
							SELECT
							dd.CustomerId 
							,dd.AccountId
							,dd.AmountToEarn
							,dd.EffectiveTimestamp 
							,23 as TransactionTypeId
							,dd.DiscountId
							,dd.CurrencyId
							,dd.Reference
					From 
							#DeferredDiscounts dd
					--Filter down to only the discounts related to the charges that were dealt with in the first step
					INNER JOIN
						#TransactionResult tr ON tr.ChargeId = dd.ChargeId
					) as Source
					on Target.Id = 0
					WHEN MATCHED THEN UPDATE SET
						Target.Amount = Target.Amount + Source.AmountToEarn
						,Target.EffectiveTimestamp = Source.EffectiveTimestamp
						,Target.ModifiedTimestamp = Source.EffectiveTimestamp
					WHEN NOT MATCHED BY TARGET THEN 
					INSERT (AccountId, CreatedTimestamp, CustomerId, Amount, EffectiveTimestamp, TransactionTypeId, Description, CurrencyId, SortOrder, ModifiedTimestamp)  
					VALUES (AccountId, GETUTCDATE(),Source.CustomerId,Source.AmountToEarn,Source.EffectiveTimestamp,Source.TransactionTypeId,NULL,Source.CurrencyId, 99, GETUTCDATE())
					Output  Inserted.Id as TransactionId
					, Source.DiscountId as DiscountId 
					,Source.AmountToEarn as Amount
					, Source.CustomerId
					, Source.AccountId
					, Source.CurrencyId
					, Source.EffectiveTimestamp
					,Source.Reference
					into 
					#DiscountTransactionResult (
					TransactionId
					, DiscountId
					, Amount
					,CustomerId
					, AccountId
					,CurrencyId
					,EffectiveTimestamp
					,Reference
					)
					;

					MERGE EarningDiscount as Target
					Using
					(
					Select
							TransactionId as Id
							,DiscountId as ChargeId
							,Reference as Reference
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
							UnearnedAmount = UnearnedAmount - dtr.Amount 
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

					DELETE eds
					FROM EarningDiscountSchedule eds
					INNER JOIN EarningSchedule es ON es.Id = eds.EarningScheduleId
					INNER JOIN #ChargesToEarn ce ON ce.EarningScheduleId = es.Id		  
              
					DELETE es
					FROM EarningSchedule es
					INNER JOIN #ChargesToEarn ce ON ce.EarningScheduleId = es.Id

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

