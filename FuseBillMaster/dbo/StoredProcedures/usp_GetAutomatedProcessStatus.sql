
CREATE PROCEDURE [dbo].[usp_GetAutomatedProcessStatus]

WITH RECOMPILE
AS
SET NOCOUNT ON

CREATE TABLE #automatedprocesses(
	LastMonthRunsAvg numeric(6,2) not null, 
	TodaysRunsAvg numeric(6,2) not null,  
	TotalEntities int not null, 
	EntitiesActioned int not null, 
	TotalEntitiesMonth int not null, 
	EntitiesActionedMonth int not null,
	AccountAutomatedHistoryTypeId tinyint not null, 
	ProcessName varchar(50) not null,
	[Status] varchar(50) null,
	ErrorRate varchar(50) null,
	LastRan DateTime not null,
	LastMonthRuns int not null, 
	TodaysRuns    int not null,  

	)

insert into  #automatedprocesses
Select 
	0.0 as 'LastMonthRunsAvg', 
	0.0 as 'TodaysRunsAvg', 
	0 as TotalEntities, 
	0 as EntitiesActioned, 
	0 as TotalEntitiesMonth, 
	0 as EntitiesActionedMonth, 
	Id as AccountAutomatedHistoryTypeId, 
	[Name] as 'ProcessName',
	'',
	'',
	'1900-01-01',
	0,
	0
from Lookup.AccountAutomatedHistoryType


select 
	ISNULL(Count(id) / (30.0 * 24.0), 0) as 'average number of runs per hour for the past month', 
	AccountAutomatedHistoryTypeId , 
	Max(CreatedTimestamp) as 'Last Ran',
	ISNULL(SUM(TotalCustomers), 0) as 'Total Customers', 
	ISNULL(SUM(CustomersActioned), 0) as 'Customers Actioned',
	ISNULL(Count(id), 0) as 'Total Runs'
into
#monthhistory
from [dbo].[AccountAutomatedHistory] 

where CreatedTimestamp > DATEADD(day, -30, GETUTCDATE())
Group by AccountAutomatedHistoryTypeId

select 
	ISNULL(SUM(TotalCustomers), 0) as 'Total Customers', 
	ISNULL(SUM(CustomersActioned), 0) as 'Customers Actioned',
	ISNULL(Count(id) / (24.0), 0) as 'average number of runs per hour for the last day', 
	AccountAutomatedHistoryTypeId,
	ISNULL(Count(id), 0) as 'Total Runs'
into
#dayhistory
from [dbo].[AccountAutomatedHistory] 
where CreatedTimestamp > DATEADD(day, -1, GETUTCDATE())
Group by AccountAutomatedHistoryTypeId


UPDATE 
    processes
SET 
	processes.TodaysRunsAvg = history.[average number of runs per hour for the last day],
	processes.TotalEntities = history.[Total Customers],
	processes.EntitiesActioned = history.[Customers Actioned],
	processes.TodaysRuns = history.[Total Runs]
FROM 
    #automatedprocesses as processes
    inner JOIN #dayhistory history ON processes.AccountAutomatedHistoryTypeId = history.AccountAutomatedHistoryTypeId 


UPDATE 
    processes
SET 
	processes.LastMonthRunsAvg = history.[average number of runs per hour for the past month],
	processes.LastRan = ISNULL(history.[Last Ran], '1900-01-01'),
	processes.TotalEntitiesMonth = history.[Total Customers],
	processes.EntitiesActionedMonth = history.[Customers Actioned],
	processes.LastMonthRuns = history.[Total Runs]
FROM 
    #automatedprocesses as processes
    inner JOIN #monthhistory history ON processes.AccountAutomatedHistoryTypeId = history.AccountAutomatedHistoryTypeId 

select ISNULL(Count(id) / (30.0 * 24.0), 0) as 'average number of runs per hour for the past month' , 
	Max(CreatedTimestamp) as 'Last Ran',
	ISNULL(SUM(TotalCustomers), 0) as 'Total Customers', 
	ISNULL(SUM(CustomersBilled), 0) as 'Customers Actioned',
	ISNULL(Count(id), 0) as 'Total Runs'
into
#billingmonthhistory
from [dbo].[AccountBilling]

where CreatedTimestamp > DATEADD(day, -30, GETUTCDATE())


select ISNULL(SUM(TotalCustomers), 0) as 'Total Customers', ISNULL(SUM(CustomersBilled), 0) as 'Customers Actioned', 
	ISNULL(Count(id) / (24.0), 0) as 'average number of runs per hour for the last day' ,
	ISNULL(Count(id), 0) as 'Total Runs'
into
#billingdayhistory
from [dbo].[AccountBilling]
where CreatedTimestamp > DATEADD(day, -1, GETUTCDATE())


UPDATE 
    processes
SET 
	processes.TodaysRunsAvg = history.[average number of runs per hour for the last day],
	processes.TotalEntities = history.[Total Customers],
	processes.EntitiesActioned = history.[Customers Actioned],
	processes.TodaysRuns = history.[Total Runs]
FROM 
    #automatedprocesses as processes
    inner JOIN #billingdayhistory history ON processes.AccountAutomatedHistoryTypeId = 12


UPDATE 
    processes
SET 
	processes.LastMonthRunsAvg = history.[average number of runs per hour for the past month],
	processes.LastRan = ISNULL(history.[Last Ran], '1900-01-01'),
	processes.TotalEntitiesMonth = history.[Total Customers],
	processes.EntitiesActionedMonth = history.[Customers Actioned],
	processes.LastMonthRuns = history.[Total Runs]
	   
FROM 
    #automatedprocesses as processes
    inner JOIN #billingmonthhistory history ON processes.AccountAutomatedHistoryTypeId = 12

UPDATE 
	processes
SET
	processes.[Status] =
		CASE 
			WHEN [TodaysRunsAvg] > LastMonthRunsAvg * 0.75 THEN 'Running'
			WHEN [TodaysRunsAvg] > LastMonthRunsAvg * 0.5 THEN 'Impacted'
			WHEN [TodaysRunsAvg] > LastMonthRunsAvg * 0.25 THEN 'Stalling'
			ELSE 'Not Running'
		END
	,processes.ErrorRate =
		CASE
			WHEN TotalEntities = 0 and TodaysRunsAvg = 0 THEN 'Undetermined'
			WHEN TotalEntities = 0 THEN 'No action'
			WHEN ((EntitiesActioned* 1.0) / TotalEntities) > 0.75 THEN 'Stable'
			WHEN ((EntitiesActioned* 1.0) / TotalEntities) > 0.5 THEN 'Unstable'
			WHEN ((EntitiesActioned* 1.0) / TotalEntities) > 0.25 THEN 'High Error Rate'
			ELSE 'Critical'
		END

FROM 
    #automatedprocesses as processes

Select * from #automatedprocesses

drop table #dayhistory
drop table #automatedprocesses
drop table #monthhistory
drop table #billingdayhistory
drop table #billingmonthhistory

SET NOCOUNT OFF

GO

