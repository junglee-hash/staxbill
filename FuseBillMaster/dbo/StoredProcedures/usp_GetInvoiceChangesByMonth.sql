CREATE procedure [dbo].[usp_GetInvoiceChangesByMonth]
       @AccountId bigint 
       ,@StartDate datetime 
as 

set nocount on
set transaction isolation level snapshot

/*** 
Skennedy: If accounts have too many invoices, this sproc explodes
We can add different accounts by environment as needed

***/
DECLARE @ExcludedAccounts TABLE ( AccountId BIGINT)
--INSERT INTO @ExcludedAccounts(AccountId) VALUES (19) --Skennedy for Local testing
--INSERT INTO @ExcludedAccounts(AccountId) VALUES (10136) --Twinspires for Prod

IF EXISTS (
	SELECT * FROM @ExcludedAccounts WHERE AccountId = @AccountId
)
BEGIN
	RAISERROR('Too many invoices',16,1)
END

declare @StartOfMonth datetime
declare @EndOfMonth datetime 



select 
       @StartOfMonth = dbo.fn_GetUtcTime (dateadd(month,-1,dateadd(day,1,EOMONTH(dbo.fn_getTimezoneTime(@StartDate,ap.TimezoneId)))),ap.timezoneid)
       ,@EndOfMonth = dbo.fn_GetUtcTime (dateadd(day,1,EOMONTH(dbo.fn_getTimezoneTime(@StartDate,ap.TimezoneId))),ap.timezoneid)
from 
       AccountPreference ap
where 
       Id = @AccountId 


declare @PreMergedResults table
(
             DateRange varchar(60)
       ,TotalAmountInvoiced money
       ,WriteOffs money
       ,SumOfCreditNotes money
       ,SumOfPayments money
       ,SumOfRefunds money
       ,OutstandingBalance money
       ,CurrencyId int
          ,SortOrder int
)

;with OldInvoice as
(
Select Max(Id) as MaxId,InvoiceId 
from InvoiceJournal 
where CreatedTimestamp < @StartOfMonth 
group by InvoiceId
),CurrentInvoice as 
(
Select Max(Id) as MaxId,InvoiceId 
from InvoiceJournal 
where CreatedTimestamp < @EndOfMonth
group by InvoiceId
)
insert into @PreMergedResults
(
DateRange 
       ,TotalAmountInvoiced 
       ,WriteOffs 
       ,SumOfCreditNotes 
       ,SumOfPayments
       ,SumOfRefunds 
       ,OutstandingBalance 
       ,CurrencyId 
	   ,SortOrder
)


Select 
       DATENAME(MONTH,isnull(@StartOfMonth,'1900-01-01') ) + ' ' + DATENAME(YEAR,isnull(@StartOfMonth,'1900-01-01') ) as DateRange
       ,sum(ij.SumOfCharges-ij.SumOfDiscounts) as TotalAmountInvoiced
       ,sum(ij.SumOfWriteOffs) as WriteOffs
       ,sum(ij.SumOfCreditNotes) as SumOfCreditNotes
       ,sum(ij.SumOfPayments) as SumOfPayments
       ,sum(ij.SumOfRefunds) as SumOfRefunds
       ,sum(ij.OutstandingBalance ) as OutstandingBalance
       ,c.CurrencyId
          ,CASE WHEN ac.IsDefault = 1 THEN 0 ELSE 1 END as SortOrder
from 
       Invoice i 
       inner join CurrentInvoice ci on i.id = ci.InvoiceId and i.AccountId = @AccountId AND i.PostedTimestamp >= @StartOfMonth 
       inner join InvoiceJournal ij on ci.MaxId  = ij.Id 
          inner join Customer c ON c.Id = i.CustomerId
          inner join AccountCurrency ac on ac.AccountId = i.AccountId AND c.CurrencyId = ac.CurrencyId
Group by c.CurrencyId,ac.IsDefault

union all

select
       'Outstanding Invoices' as DateRange
       ,sum(oij.OutstandingBalance ) as InvoiceAmount
       ,sum (ij.SumOfWriteOffs-oij.SumOfWriteOffs)   as WriteOffs
       ,sum(ij.SumOfCreditNotes-oij.SumOfCreditNotes) as sumOfCreditNotes
       ,sum(ij.SumOfPayments- oij.SumOfPayments) as SumOfPayments
       ,sum(ij.SumOfRefunds-oij.SumOfRefunds) as SumOfRefunds
       ,sum(ij.OutstandingBalance ) as OutstandingBalance
       ,c.CurrencyId 
          ,CASE WHEN ac.IsDefault = 1 THEN 2 ELSE 3 END as SortOrder
from 
       Invoice i  
       inner join CurrentInvoice ci on i.id = ci.InvoiceId  and i.AccountId = @AccountId AND i.PostedTimestamp < @StartOfMonth 
       inner join InvoiceJournal ij on ci.MaxId  = ij.Id 
       inner join OldInvoice oi on oi.InvoiceId = i.id 
       inner join InvoiceJournal oij on oi.MaxId = oij.id 
          inner join Customer c ON c.Id = i.CustomerId
          inner join AccountCurrency ac on ac.AccountId = i.AccountId AND c.CurrencyId = ac.CurrencyId
Group by c.CurrencyId, ac.IsDefault  


merge into
       @PreMergedResults as target
       using
       (
       select 
              DATENAME(MONTH,isnull(@StartOfMonth,'1900-01-01') ) + ' ' + DATENAME(YEAR,isnull(@StartOfMonth,'1900-01-01') ) as DateRange
              , ac.CurrencyId
                      ,CASE WHEN ac.IsDefault = 1 THEN 0 ELSE 1 END as SortOrder
       from 
              accountCurrency ac
       where 
              ac.AccountId = @AccountId AND ac.CurrencyStatusId = 2
       union  
       select 
              'Outstanding Invoices' as DateRange
              , ac.CurrencyId
                      ,CASE WHEN ac.IsDefault = 1 THEN 2 ELSE 3 END as SortOrder
       from 
              accountCurrency ac
       where 
              ac.AccountId = @AccountId AND ac.CurrencyStatusId = 2
       --union 
       --select 
       --       'Old Outstanding Balance' as DateRange
       --       ,1 as CurrencyId
       --union 
       --select 
       --       'January' as DateRange
       --       ,1 as CurrencyId
       ) as source
       on target.DateRange = source.DateRange
       and target.CurrencyId = source.CurrencyId
When not matched by target
       THEN Insert 
       (
              DateRange
              ,TotalAmountInvoiced 
                       ,WriteOffs 
                       ,SumOfCreditNotes 
                       ,SumOfPayments 
                       ,SumOfRefunds 
                       ,OutstandingBalance 
                       ,CurrencyId 
                       ,SortOrder
       )
       values
       (
              Source.DateRange
              ,null
       ,null
       ,null
       ,null
       ,null
       ,null
       ,Source.CurrencyId
          ,Source.SortOrder
       );
select 
       DateRange
       ,TotalAmountInvoiced 
       ,WriteOffs 
       ,SumOfCreditNotes 
       ,SumOfPayments 
       ,SumOfRefunds 
       ,OutstandingBalance 
       ,CurrencyId 
From
       @PreMergedResults
ORDER BY SortOrder

GO

