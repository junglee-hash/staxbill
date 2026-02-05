
CREATE   PROCEDURE [dbo].[usp_GetCustomerEmailSummaryReportCSV]
	--required
	@AccountId BIGINT,

	--Paging variables
	@SortOrder NVARCHAR(255),
	@SortExpression NVARCHAR(255),
	@PageNumber BIGINT,
	@PageSize BIGINT,

	--Filtering options
	@CustomerId BIGINT = NULL,
	@ToEmail NVARCHAR(255) = NULL,
	@CompanyName NVARCHAR(255) = NULL,
	@Status NVARCHAR(255) = NULL,

	@DeliveryResultSet BIT = 0,
	@DeliveryResult NVARCHAR(255) = NULL,
	@SearchingForMiscellaneousDeliveryResults bit = 0,
	@SearchingForNullDeliveryResults bit = 0,
	@EmailType NVARCHAR(255) = NULL,

	@CreatedDateSet BIT = 0,
	@CreatedDateStartDate DATETIME = NULL,
	@CreatedDateEndDate DATETIME = NULL,

	@SalesTrackingCode1Code NVARCHAR(255) = NULL,
	@SalesTrackingCode2Code NVARCHAR(255) = NULL,
	@SalesTrackingCode3Code NVARCHAR(255) = NULL,
	@SalesTrackingCode4Code NVARCHAR(255) = NULL,
	@SalesTrackingCode5Code NVARCHAR(255) = NULL

WITH RECOMPILE
AS
SET NOCOUNT ON

	declare @TimezoneId int

	select @TimezoneId = TimezoneId
	from AccountPreference where Id = @AccountId 


Select 
	*
INTO
	#CustomerEmailLogsTemp
	 from [dbo].[CustomerEmailSummaryCollection](

	 @AccountId
	,@CustomerId 
	,@ToEmail
	,@CompanyName
	,@Status
	,@DeliveryResultSet
	,@DeliveryResult  
	,@SearchingForMiscellaneousDeliveryResults 
	,@SearchingForNullDeliveryResults 
	,@EmailType
	,@CreatedDateSet 
	,@CreatedDateStartDate 
	,@CreatedDateEndDate
	,@SalesTrackingCode1Code
	,@SalesTrackingCode2Code
	,@SalesTrackingCode3Code
	,@SalesTrackingCode4Code
	,@SalesTrackingCode5Code
)


declare @sqltext nvarchar(3000)
set @sqltext = N'SELECT 	
     tmp.CustomerId  AS FusebillId
	,c.reference as CustomerReference
    ,c.CompanyName as CompanyName
	,c.FirstName + '' '' + c.LastName as [First and Last Name]
	,tmp.ToEmail
	,tmp.[EmailType] as [Email Type]
	,tmp.CustomerEmailLogId as [Email ID]
	,CASE WHEN tmp.BccEmail LIKE ''%'' + tmp.EmailSummaryToEmail + ''%'' THEN ''1''  ELSE ''0'' END As BCCIndicator
	,dbo.fn_GetTimezoneTime(tmp.EffectiveTimestamp, @TimezoneId) as [Email Triggered Timestamp]
	,dbo.fn_GetTimezoneTime(tmp.CreatedTimestamp, @TimezoneId) as CreatedTimestamp
	,dbo.fn_GetTimezoneTime(tmp.ProcessedTimestamp, @TimezoneId) AS [Email Processed Timestamp]
	,dbo.fn_GetTimezoneTime(tmp.DeliveredTimestamp, @TimezoneId) AS [Email Delivered Timestamp]
	,dbo.fn_GetTimezoneTime(tmp.OpenedTimestamp, @TimezoneId) AS [Email Opened Timestamp]
	,dbo.fn_GetTimezoneTime(tmp.LastUpdatedTimestamp, @TimezoneId) AS [Email Last Updated Timestamp]
	,CASE WHEN tmp.DeliveryResult IS NULL THEN ''not sent'' ELSE tmp.DeliveryResult END AS [Last Known Status]
	,tmp.Reason AS [Email status Reason]
	,tmp.Attempt
	,es.name as [Status]
	FROM #CustomerEmailLogsTemp tmp
	inner join customer c on c.Id = tmp.CustomerId
	inner join [Lookup].[EmailStatus] es on es.Id = tmp.status 
	
	order by CASE When @SortOrder = ''Ascending'' THEN '+'tmp.'+@SortExpression+' END ASC, CASE When @SortOrder = ''Descending'' THEN '+'tmp.'+@SortExpression+' END DESC'

--PRINT @sqltext

execute sp_executesql @sqltext, N'@SortOrder NVARCHAR(255), @TimezoneId int',@SortOrder = @SortOrder, @TimezoneId = @TimezoneId

DROP Table #CustomerEmailLogsTemp

SET NOCOUNT OFF

GO

