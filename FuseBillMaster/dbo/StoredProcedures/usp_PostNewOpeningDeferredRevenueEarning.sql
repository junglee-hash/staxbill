CREATE Procedure [dbo].[usp_PostNewOpeningDeferredRevenueEarning]

       @AccountId bigint = 0
       ,@UtcDateTime datetime = null
AS


if @UtcDateTime is null
       set @UtcDateTime = GETUTCDATE()
Begin TRY
       set nocount on
              create  table #ModifiedEndTimestamp
              (
                     RunDateTime datetime,      
                     UtcPeriodEndOfDate datetime,         
                     UtcPeriodStartOfDate datetime,  
                     Id bigint primary key
              )
              ; WITH UtcEndTimestamp as
              (
                     select 
                           TZ.Id as Id,
                           @UtcDateTime  as RunDateTime,
                           Case 
                                  when ttd.Id is null 
                                  then dateadd(minute,-OffsetfromUTCMinute,dateadd(hour,-OffsetFromUTCHour,
                                         convert(datetime,convert(date,Dateadd(minute,OffsetfromUTCMinute, dateadd(hour, OffsetFromUTCHour,@UtcDateTime))))))
                                  ELSE
                                         dateadd(minute,-DSTOffsetfromUTCMinute,dateadd(hour,-DSTOffsetFromUTCHour,convert(datetime,convert(date,Dateadd(minute,DSTOffsetfromUTCMinute, dateadd(hour, DSTOffsetFromUTCHour,@UtcDateTime ))))))
                           END as UtcPeriodStartOfDate       
                     from 
                           lookup.timezone tz with (readpast)
                           left join lookup.DaylightSavingsTransitionDates ttd  with (readpast)
                           on tz.Id = ttd.Id
                           and ttd.TransitionStart <= @UtcDateTime
                           and ttd.TransitionEnd > @UtcDateTime
              ),
              ModifiedEndTimestamp as 
              (
                     select 
                           MED.RunDateTime           
                           , MED.Id as Id
                           ,case
                                  when MED.RunDateTime < TransitionEnd and MED.UtcPeriodStartOfDate >= TransitionEnd 
                                  then dateadd(hour, 1, MED.UtcPeriodStartOfDate)
                                  when MED.RunDateTime < TransitionStart and MED.UtcPeriodStartOfDate >= TransitionStart 
                                  then dateadd(hour, -1, MED.UtcPeriodStartOfDate)          
                                  else MED.UtcPeriodStartOfDate
                           end as UtcPeriodStartOfDate
                     From 
                           UtcEndTimestamp as MED
                           left join lookup.DaylightSavingsTransitionDates AS DSTD  with (readpast) on MED.Id = DSTD.Id
                           and ( 
                                         (DSTD.TransitionStart <= MED.UtcPeriodStartOfDate and DSTD.TransitionEnd > MED.UtcPeriodStartOfDate)
                                         or
                                         (DSTD.TransitionStart <= @UtcDateTime  and DSTD.TransitionEnd > @UtcDateTime )
                                  )
              )
              Insert into
                     #ModifiedEndTimestamp(Id,RunDateTime,UtcPeriodStartOfDate )
              SELECT
                     Id
                     ,RunDateTime
                     ,UtcPeriodStartOfDate 
              from
                     ModifiedEndTimestamp


              Create table #EarningList
              (
                     OpeningDeferredRevenueId bigint
                     ,OriginalChargeAmount money 
                     ,RemainingDeferredRevenue decimal(18,2)
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
                     ,TimezoneId int
              )

              create table #TransactionResult
              (
                     TransactionId bigint
                     ,CustomerId bigint
					 ,AccountId bigint
                     ,Amount money
                     ,OpeningDeferredRevenueId Bigint
                     ,EffectiveTimestamp datetime
                     ,CurrencyId bigint
                     ,NextEarningTimestamp datetime
              )

              CREATE INDEX 
                     [IX_#TransactionResult] 
                     ON  #TransactionResult (TransactionId)

              ;with EarnedRevenue as
                     (
                     select
                           e.OpeningDeferredRevenueId 
                           ,sum(t.Amount ) as EarnedRevenue
                     from 
                           [Transaction] t  with (readpast)
                           inner join EarningOpeningDeferredRevenue e  with (readpast)
                           on T.Id = e.Id
                           --inner join Customer c  with (readpast)
                           --on t.CustomerId = c.Id
                     group by 
                           e.OpeningDeferredRevenueId 
                     )
                     
                     Insert into #EarningList 
                     (
                           OpeningDeferredRevenueId-- bigint
                           ,OriginalChargeAmount --money 
                           ,RemainingDeferredRevenue-- decimal(10,2)
                           ,CustomerId --bigint
						   ,AccountId --bigint
                           ,CurrencyId --bigint           
                           ,EarningStartDate --datetime
                           ,EarningEndDate --datetime
                           ,RelativeEarningTimestamp 
                           ,EarningTimingIntervalId --int
                           ,EarningTimingTypeId --int
                           ,TimezoneId
                     )
                     /************************************Charges due for new Earning Records*****************************************/
                     Select 
                           t.Id  as OpeningDeferredRevenueId
                           ,t.Amount as OriginalChargeAmount
                           ,t.Amount - isnull(er.EarnedRevenue ,0) RemainingDeferredRevenue
                           ,c.Id as Customerid
						   ,t.AccountId as AccountId
                           ,c.CurrencyId 
                           ,ch.EarningStartDate 
                           ,ch.EarningEndDate
                           ,med.UtcPeriodStartOfDate 
                           ,ch.EarningTimingIntervalId 
                           ,ch.EarningTimingTypeId 
                           ,med.Id
                     From
                           Customer c  with (readpast)
                           inner join [Transaction] t  with (readpast)
                           on t.CustomerId = c.Id 
                           inner join OpeningDeferredRevenue ch  with (readpast)
                           on t.Id = ch.Id
                           inner join AccountPreference  a  with (readpast) 
                           on c.AccountId = a.Id   
                           inner join #ModifiedEndTimestamp med 
                           on a.TimezoneId = med.Id 
                           left join EarnedRevenue er
                           on ch.Id = er.OpeningDeferredRevenueId 
                     Where 
                           t.TransactionTypeId != 19
                           and c.AccountId =  isnull(@AccountId ,c.AccountId) 
                           and ch.CompletedEarningTimestamp is null
                           and ch.EarningTimingIntervalId != 3
                           and ch.EarningTimingTypeId != 3
                          -- and c.StatusId != 3 --Cancelled
                           and t.Amount - isnull(er.EarnedRevenue ,0) >0
                           and ch.NextEarningTimestamp  <= med.UtcPeriodStartOfDate;
                     --OPTION (MAXDOP 1);

              Update el
              SET 
                     PeriodsEarned = datediff(day,EarningStartDate,RelativeEarningTimestamp)
                     ,TotalPeriods = datediff(day,EarningStartDate , EarningEndDate)
                     ,NextEarningTimestamp = dbo.fn_GetUtcTime( dateadd(day,-(datediff(day,dbo.fn_GetTimezoneTime (RelativeEarningTimestamp,TimezoneId )  , convert(date,dbo.fn_GetTimezoneTime(EarningEndDate,TimezoneId )))-1),convert(date,dbo.fn_GetTimezoneTime(EarningEndDate,TimezoneId ))),TimezoneId)
              from 
                     #EarningList el
              WHERE
                     el.EarningTimingIntervalId = 1


              Update el
              SET 
                     PeriodsEarned = datediff(month,EarningStartDate,RelativeEarningTimestamp)
                     ,TotalPeriods = datediff(month,EarningStartDate , EarningEndDate)
                     ,NextEarningTimestamp = dbo.fn_GetUtcTime( dateadd(month,-(datediff(month,dbo.fn_GetTimezoneTime (RelativeEarningTimestamp,TimezoneId )  ,convert(date, dbo.fn_GetTimezoneTime(EarningEndDate,TimezoneId )))-1),convert(date,dbo.fn_GetTimezoneTime(EarningEndDate,TimezoneId ))),TimezoneId)
              from 
                     #EarningList el
              WHERE
                     el.EarningTimingIntervalId = 4

              Update el
              SET 
                     PeriodsEarned = datediff(year,EarningStartDate,RelativeEarningTimestamp)
                     ,TotalPeriods = datediff(year,EarningStartDate , EarningEndDate)
                     ,NextEarningTimestamp = dbo.fn_GetUtcTime( dateadd(year,-(datediff(year,dbo.fn_GetTimezoneTime (RelativeEarningTimestamp,TimezoneId )  ,convert(date, dbo.fn_GetTimezoneTime(EarningEndDate,TimezoneId )))-1),convert(date,dbo.fn_GetTimezoneTime(EarningEndDate,TimezoneId ))),TimezoneId)
              from 
                     #EarningList el
              WHERE
                     el.EarningTimingIntervalId = 5;
              --OPTION (MAXDOP 1);




              Update #EarningList 
              SET
                     RemainingEarningPeriods = TotalPeriods - PeriodsEarned - case when EarningTimingTypeId = 1 then  1   else 0 END;
              --OPTION (MAXDOP 1);

              Update #EarningList 
              SET
                     RemainingEarningPeriods = case when RemainingEarningPeriods < 0 then 0 else RemainingEarningPeriods end
                     , TotalPeriods = case when TotalPeriods < 1 then 1 else TotalPeriods END;
              --OPTION (MAXDOP 1);


              Update #EarningList 
              SET 
                     AmountToEarn  =  round(OriginalChargeAmount  *(TotalPeriods- RemainingEarningPeriods  ) / TotalPeriods,2) - (OriginalChargeAmount  - RemainingDeferredRevenue  );
              --OPTION (MAXDOP 1);

              Update #EarningList 
              SET 
                     AmountToEarn  =  0 where AmountToEarn < 0;
              --OPTION (MAXDOP 1);

              
              BEGIN TRANSACTION
              Merge  [Transaction] as Target
              Using
              (
              SELECT
                     Getutcdate()  as CreatedTimestamp
					 ,Getutcdate()  as ModifiedTimestamp
                     ,CustomerId as CustomerId
					 ,AccountId
                     ,AmountToEarn  as Amount
                     ,@UtcDateTime   as EffectiveTimestamp
                     ,27 as TransactionTypeId
                     ,null as Description
                     ,CurrencyId as CurrencyId
                     ,OpeningDeferredRevenueId
                     ,nextEarningTimestamp
                     From
                     #EarningList 
              ) as Source
              on null = source.CustomerId
              WHEN NOT MATCHED BY TARGET THEN 
              INSERT (AccountId, CreatedTimestamp, CustomerId, Amount, EffectiveTimestamp, TransactionTypeId, Description, CurrencyId, SortOrder, ModifiedTimestamp)  
              VALUES (Source.AccountId, GETUTCDATE(),Source.CustomerId,Source.Amount,Source.EffectiveTimestamp,Source.TransactionTypeId,Source.Description,Source.CurrencyId, 99, Source.ModifiedTimestamp)
              Output  
                     INSERTED.Id
                     , Inserted.CustomerId
					 , Inserted.AccountId
                     , Inserted.Amount
                     , Inserted.EffectiveTimestamp
                     , Source.OpeningDeferredRevenueId
                     , inserted.CurrencyId
                     ,Source.NextEarningTimestamp
              into #TransactionResult  
              (
                     TransactionId
                     ,CustomerId
					 ,AccountId
                     ,Amount
                     ,EffectiveTimestamp
                     , OpeningDeferredRevenueId
                     , CurrencyId
                     ,NextEarningTimestamp
              );  
              --OPTION (MAXDOP 1);

              Insert into EarningOpeningDeferredRevenue 
              (
                     Id
                     , OpeningDeferredRevenueId
                     , Reference
              )
              Select
                     TransactionId as Id
                     ,OpeningDeferredRevenueId as OpeningDeferredRevenueId
                     ,Null as Reference
              from 
                     #TransactionResult;  
              --OPTION (MAXDOP 1);

              Update 
                     cle
              set 
                     cle.NextEarningTimestamp = tr.NextEarningTimestamp
              from
                     OpeningDeferredRevenue cle
                     inner join #TransactionResult tr
                     on cle.Id = tr.OpeningDeferredRevenueId 

       
			  Create table #CompletedCharges 
	(
	OpeningDeferredRevenueId bigint not null
	)
		;with EarnedRevenue as
		(
		select
			e.OpeningDeferredRevenueId 
			,sum(t.Amount ) as EarnedRevenue
		from 
			[Transaction] t
			inner join EarningOpeningDeferredRevenue e
			on T.Id = e.Id
			inner join Customer c
			on t.CustomerId = c.Id
		group by 
			e.OpeningDeferredRevenueId 
		)
		Insert into #CompletedCharges  (OpeningDeferredRevenueId)
		Select Ch.Id
		From
			Customer c
			inner join [Transaction] t
			on t.CustomerId = c.Id 
			inner join OpeningDeferredRevenue ch
			on t.Id = ch.Id
			left join EarnedRevenue er
			on ch.Id = er.OpeningDeferredRevenueId 
		Where 
			t.Amount - isnull(er.EarnedRevenue ,0) = 0
			and c.AccountId = @AccountId 
			and CompletedEarningTimestamp is null


update cle set CompletedEarningTimestamp = @UtcDateTime
		From
			OpeningDeferredRevenue cle
			inner join 
			#CompletedCharges cc
			on cle.Id  = cc.OpeningDeferredRevenueId

drop table #CompletedCharges 



              declare @Count int
              set @Count = (Select Count(*) from #TransactionResult )
              if @Count is null 
                     set @Count = 0

              drop table #EarningList
              drop table #ModifiedEndTimestamp
              drop table #TransactionResult
              set nocount off
       COMMIT TRANSACTION

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

GO

