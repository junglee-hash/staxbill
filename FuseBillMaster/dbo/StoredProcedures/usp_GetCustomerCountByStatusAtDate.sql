CREATE procedure [dbo].[usp_GetCustomerCountByStatusAtDate]
       @AccountId bigint = 20,
       @EndDate datetime = null,
       @CurrencyId int = null,
       @MonthsBack nvarchar(max) = null,
       @SalesTrackingCodeType int = null,
       @SalesTrackingCodeId bigint = null

as

DECLARE @SQL nvarchar(max)

-- Check to see if EndDate is null, if it is, this is a current query for this point in time.
IF (@EndDate is null)
	BEGIN
		SELECT @SQL = N'
		SELECT SYSDATETIME() as CountsDate, cs.Id as StatusId, Count(a.StatusId) as Count
		FROM Lookup.CustomerStatus cs
		LEFT JOIN 
			(
				SELECT c.StatusId from Customer c ' +
				CASE WHEN @SalesTrackingCodeType is not null THEN
              ' inner join CustomerReference cr (NOLOCK) ON cr.Id = c.Id' ELSE '' END +
       CASE WHEN @SalesTrackingCodeType = 1 THEN
              ' AND cr.SalesTrackingCode1Id = @SalesTrackingCodeId' ELSE '' END +
       CASE WHEN @SalesTrackingCodeType = 2 THEN
              ' AND cr.SalesTrackingCode2Id = @SalesTrackingCodeId' ELSE '' END +
       CASE WHEN @SalesTrackingCodeType = 3 THEN
              ' AND cr.SalesTrackingCode3Id = @SalesTrackingCodeId' ELSE '' END +
       CASE WHEN @SalesTrackingCodeType = 4 THEN
              ' AND cr.SalesTrackingCode4Id = @SalesTrackingCodeId' ELSE '' END +
       CASE WHEN @SalesTrackingCodeType = 5 THEN
              ' AND cr.SalesTrackingCode5Id = @SalesTrackingCodeId' ELSE '' END +
				' where c.AccountId = @AccountId and c.IsDeleted = 0
				) as a
				 ON cs.Id = a.StatusId
		GROUP BY cs.Id'

		EXEC sp_executesql @SQL, N'@AccountId bigint, @SalesTrackingCodeId bigint', @AccountId, @SalesTrackingCodeId
	END
ELSE
-- Otherwise this is an historic query
Begin
IF (@MonthsBack is null)
       BEGIN
              SET @MonthsBack = '0'
       END


DECLARE @MonthsBackTable TABLE
(
Id bigint
,MonthsBack nvarchar (max)
)

INSERT INTO @MonthsBackTable (Id, MonthsBack )
SELECT * FROM dbo.Split(@MonthsBack, '|')

-- DEBUG for MONTHSBACKTABLE
       -- SELECT * from @MonthsBackTable

CREATE table #Dates ( CountsDate datetime )

INSERT INTO #Dates (CountsDate)
SELECT
       dateadd(month,-1*cast(MonthsBack as int), @EndDate)
FROM @MonthsBackTable

-- DEBUG for DATES
       -- SELECT * FROM #Dates

CREATE table #CurrentStatusJournal
(
       CustomerId bigint
       ,CurrentSequenceNumber int
       ,CountsDate datetime
)

INSERT into #CurrentStatusJournal (CustomerId, CurrentSequenceNumber, CountsDate)
SELECT
       CustomerId
       ,Max(ssj.SequenceNumber) as CurrentSequenceNumber
       ,ds.CountsDate
FROM
       CustomerStatusJournal ssj (NOLOCK)
       inner join Customer c (NOLOCK) on ssj.CustomerId = c.Id 
       inner join #Dates ds on ssj.CreatedTimestamp < ds.CountsDate 
WHERE
       c.AccountId =@AccountId
       and ssj.CreatedTimestamp < @EndDate
       and c.CurrencyId = isnull(@CurrencyId, c.CurrencyId)
	   and c.IsDeleted = 0
GROUP BY
       CustomerId, ds.CountsDate

-- DEBUG for #CurrentStatusJournal and CustomerStatusJournal
-- SELECT * FROM #CurrentStatusJournal
-- SELECT * FROM CustomerStatusJournal WHERE CustomerId IN (SELECT CUSTOMERID FROM #CurrentStatusJournal) 
-- SELECT COUNT(CUSTOMERID), STATUSID FROM CustomerStatusJournal WHERE CustomerId IN (SELECT CUSTOMERID FROM #CurrentStatusJournal) GROUP BY STATUSID
-- SELECT 'CustomerStatusJournal', * FROM CustomerStatusJournal WHERE CustomerId IN (SELECT CUSTOMERID FROM #CurrentStatusJournal) AND ISACTIVE = 1 AND STATUSID = 1

SELECT @SQL = N'
SELECT
       ds.CountsDate,
       cs.Id as StatusId,
       isnull(ExistingCounts.Count,0) as Count
       
FROM #Dates ds
inner join Lookup.CustomerStatus cs on 1 = 1
left join
       (SELECT csj.CountsDate, ssj.StatusId, count(ssj.StatusId) as Count
       FROM #CurrentStatusJournal csj
       inner join CustomerStatusJournal ssj (NOLOCK) ON ssj.CustomerId = csj.CustomerId AND csj.CurrentSequenceNumber = ssj.SequenceNumber' +
       CASE WHEN @SalesTrackingCodeType is not null THEN
              ' inner join CustomerReference cr (NOLOCK) ON cr.Id = csj.CustomerId' ELSE '' END +
       CASE WHEN @SalesTrackingCodeType = 1 THEN
              ' AND cr.SalesTrackingCode1Id = @SalesTrackingCodeId' ELSE '' END +
       CASE WHEN @SalesTrackingCodeType = 2 THEN
              ' AND cr.SalesTrackingCode2Id = @SalesTrackingCodeId' ELSE '' END +
       CASE WHEN @SalesTrackingCodeType = 3 THEN
              ' AND cr.SalesTrackingCode3Id = @SalesTrackingCodeId' ELSE '' END +
       CASE WHEN @SalesTrackingCodeType = 4 THEN
              ' AND cr.SalesTrackingCode4Id = @SalesTrackingCodeId' ELSE '' END +
       CASE WHEN @SalesTrackingCodeType = 5 THEN
              ' AND cr.SalesTrackingCode5Id = @SalesTrackingCodeId' ELSE '' END +

       ' GROUP BY csj.CountsDate, ssj.StatusId) as ExistingCounts
       on ds.CountsDate = ExistingCounts.CountsDate and cs.Id = ExistingCounts.StatusId

       DROP table #Dates
       DROP table #CurrentStatusJournal'


EXEC sp_executesql @SQL, N'@SalesTrackingCodeId bigint', @SalesTrackingCodeId
End

GO

