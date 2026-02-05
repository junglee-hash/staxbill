CREATE   PROCEDURE [dbo].[usp_GetCustomerEmailSummary]
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

	@CreatedDateSet bit = 0,
	@CreatedDateStartDate DateTime = NULL,
	@CreatedDateEndDate DateTime = NULL,

	@SalesTrackingCode1Code NVARCHAR(255) = NULL,  
	@SalesTrackingCode2Code NVARCHAR(255) = NULL,	  
	@SalesTrackingCode3Code NVARCHAR(255) = NULL,	  
	@SalesTrackingCode4Code NVARCHAR(255) = NULL,  
	@SalesTrackingCode5Code NVARCHAR(255) = NULL

WITH RECOMPILE
AS
SET NOCOUNT ON


SELECT 
	*
INTO
	#CustomerEmailLogsTemp
	 FROM [dbo].[CustomerEmailSummaryCollection](

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


DECLARE @sqltext NVARCHAR(3000)


SET @sqltext = N'SELECT 
tmp.CustomerEmailLogId,
c.Id as CustomerId,
c.Reference as CustomerReference,
c.companyName as CompanyName,
c.FirstName as CustomerFirstName,
c.LastName as CustomerLastName,
c.PrimaryEmail as PrimaryEmail,
c.ParentId as CustomerParentId,
c.IsParent as CustomerIsParent,
cas.[Name] as AccountingStatus,
cs.[Name] as CustomerStatus,
tmp.EffectiveTimestamp,
tmp.CreatedTimestamp,
tmp.LastUpdatedTimestamp,
tmp.DeliveredTimestamp,
tmp.OpenedTimestamp,
tmp.ProcessedTimestamp,
tmp.Subject,
tmp.ToEmail,
tmp.ToDisplayName,
tmp.BccEmail,
tmp.BccDisplayName,
tmp.FromEmail,
tmp.FromDisplayName,
tmp.Body,
tmp.Status,
tmp.Result,
tmp.DeliveryResult,
tmp.Reason,
tmp.SendgridEmailId,
tmp.EmailType

FROM #CustomerEmailLogsTemp tmp
inner join customer c on c.Id = tmp.CustomerId
INNER JOIN dbo.CustomerReference AS cr ON cr.Id = c.Id
inner join lookup.CustomerAccountStatus cas on cas.Id = c.AccountStatusId
inner join lookup.CustomerStatus cs on cs.Id = c.StatusId

order by CASE When @SortOrder = ''Ascending'' THEN '+ 'tmp.'+@SortExpression+' END ASC, CASE When @SortOrder = ''Descending'' THEN '+'tmp.'+ @SortExpression +' END DESC OFFSET (@PageNumber * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY'
EXECUTE sp_executesql @sqltext, N'@SortOrder NVARCHAR(255), @SortExpression NVARCHAR(255), @PageSize BIGINT, @PageNumber BIGINT',
@SortOrder = @SortOrder, @SortExpression = @SortExpression, @PageNumber = @PageNumber, @PageSize = @PageSize

--PRINT @sqltext

SET @sqltext = N'SELECT Count(1) as [count] from #CustomerEmailLogsTemp'
EXECUTE sp_executesql @sqltext 

DROP Table #CustomerEmailLogsTemp

SET NOCOUNT OFF

GO

