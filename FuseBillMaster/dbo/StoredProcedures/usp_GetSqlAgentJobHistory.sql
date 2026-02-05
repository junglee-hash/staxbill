CREATE PROCEDURE [dbo].[usp_GetSqlAgentJobHistory]
	--Paging variables
	@SortOrder NVARCHAR(255) = 'Descending',
	@SortExpression NVARCHAR(255) = 'RunDateTime',
	@PageNumber BIGINT = 0,
	@PageSize BIGINT = 10,

	--Filtering options
	@JobName NVARCHAR(255) = '',
	@JobNameSet BIT = 0
AS

DECLARE @SQL NVARCHAR(2000)
SET @SQL = '
;WITH JobHistory AS (
SELECT j.name as JobName
    ,jh.step_name as StepName
    ,CASE WHEN jh.sql_severity = 0 THEN 1 ELSE 0 END as StepStatus
    ,jh.message as Result  
	,cast(cast(jh.run_date as char(8))+'' ''+stuff(stuff(right(''000000''+convert(varchar(6),jh.run_time),6),3,0,'':''),6,0,'':'') as datetime)  as RunDateTime
	,(run_duration/10000*3600 + (run_duration/100)%100*60 + run_duration%100 + 31 ) as RunDurationSeconds
FROM msdb.dbo.sysjobs AS j
INNER JOIN msdb.dbo.sysjobhistory AS jh
   ON jh.job_id = j.job_id

'

IF @JobNameSet = 1
BEGIN
	SET @SQL = @SQL + ' WHERE j.Name LIKE ''%' + @JobName + '%'''
END

SET @SQL = @SQL + '
)
SELECT
	*
FROM JobHistory
ORDER BY CASE WHEN @SortOrder = ''Ascending'' THEN '+@SortExpression+' END ASC, CASE WHEN @SortOrder = ''Descending'' THEN '+@SortExpression+' END DESC OFFSET (@PageNumber * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
'

EXECUTE sp_executesql @SQL, N'@PageNumber BIGINT,@PageSize BIGINT, @SortOrder NVARCHAR(255)',@SortOrder = @SortOrder, @PageNumber = @PageNumber, @PageSize = @PageSize

GO

