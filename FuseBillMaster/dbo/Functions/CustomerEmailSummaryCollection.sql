
CREATE   FUNCTION [dbo].[CustomerEmailSummaryCollection]
(
--required
@AccountId BIGINT,

--Filtering options
@CustomerId BIGINT = NULL,
@ToEmail NVARCHAR(255) = NULL,
@CompanyName NVARCHAR(255) = NULL,
@Status NVARCHAR(255) = NULL,
@DeliveryResultSet BIT = 0,
@DeliveryResult NVARCHAR(255) = NULL,
@SearchingForMiscellaneousDeliveryResults BIT = 0,
@SearchingForNullDeliveryResults BIT = 0,
@EmailType NVARCHAR(255) = NULL,

@CreatedDateSet BIT,
@CreatedDateStartDate DATETIME,
@CreatedDateEndDate DATETIME,

@SalesTrackingCode1Code NVARCHAR(255) = NULL,
@SalesTrackingCode2Code NVARCHAR(255) = NULL,
@SalesTrackingCode3Code NVARCHAR(255) = NULL,
@SalesTrackingCode4Code NVARCHAR(255) = NULL,
@SalesTrackingCode5Code NVARCHAR(255) = NULL
)
RETURNS TABLE
AS
RETURN

WITH AccountEmailLogs AS (
SELECT 
	Id,
	CustomerId,
	EffectiveTimestamp,
	CreatedTimestamp,
	[Subject],
	ToDisplayName,
	BccEmail,
	BccDisplayName,
	FromEmail,
	FromDisplayName,
	EmailTypeId,
	SendgridEmailId,
	ToEmail,
	Body,
	StatusId,
	Result
	FROM CustomerEmailLog
	WHERE accountId = @AccountId
), FilteredContent AS (
SELECT
  cel.[Id] AS CustomerEmailLogId
 ,cel.CustomerId  AS CustomerId
 ,cel.EffectiveTimestamp AS 'EffectiveTimestamp'
 ,cel.CreatedTimestamp AS 'CreatedTimestamp'
 ,cees.LastUpdatedTimestamp
 ,cees.DeliveredTimestamp
 ,cees.OpenedTimestamp
 ,cees.ProcessedTimestamp
 ,cel.[Subject]
 ,cees.[ToEmail] as EmailSummaryToEmail
 ,CASE WHEN cees.[ToEmail] is null THEN cel.[ToEmail] ELSE cees.ToEmail END As ToEmail
 ,cel.ToDisplayName
 ,cel.BccEmail
 ,cel.BccDisplayName
 ,cel.FromEmail
 ,cel.FromDisplayName
 ,cel.Body
 ,cel.StatusId as [Status]
 ,cel.Result
 ,cees.DeliveryResult
 ,cees.Reason as Reason
 ,cees.Attempt
 ,cel.EmailTypeId as [EmailTypeId]
 ,cel.SendgridEmailId
 ,et.[Name] as [EmailType]

FROM AccountEmailLogs cel
INNER JOIN Customer c ON cel.CustomerId = c.Id and c.AccountId = @AccountId
   LEFT JOIN Lookup.EmailType et ON cel.EmailTypeId = et.Id
   LEFT JOIN CustomerEmailEventSummary cees ON cees.CustomerEmailLogId = cel.Id and cees.AccountId = @AccountId
   INNER JOIN dbo.CustomerReference AS cr ON cr.Id = c.Id
   LEFT JOIN SalesTrackingCode stc1 ON cr.SalesTrackingCode1Id = stc1.Id
   LEFT JOIN SalesTrackingCode stc2 ON cr.SalesTrackingCode2Id = stc2.Id
   LEFT JOIN SalesTrackingCode stc3 ON cr.SalesTrackingCode3Id = stc3.Id
   LEFT JOIN SalesTrackingCode stc4 ON cr.SalesTrackingCode4Id = stc4.Id
   LEFT JOIN SalesTrackingCode stc5 ON cr.SalesTrackingCode5Id = stc5.Id
WHERE
	(@CustomerId IS NULL OR CustomerId = @CustomerId)
AND (@Status IS NULL OR cel.StatusId IN (SELECT DATA FROM dbo.Split(@Status,',')))
AND (@DeliveryResultSet = 0
	OR (
	DeliveryResult IN (SELECT DATA FROM dbo.Split(@DeliveryResult,','))
	)
	OR (
	@SearchingForNullDeliveryResults = 1 AND DeliveryResult IS NULL
	)
	OR (
	@SearchingForMiscellaneousDeliveryResults = 1 AND DeliveryResult NOT IN ('processed','dropped','deferred','bounce','delivered','open')
	)
)
AND (@EmailType IS NULL OR [EmailTypeId] IN (SELECT DATA FROM dbo.Split(@EmailType,',')))
AND (@CreatedDateSet = 0 OR (@CreatedDateStartDate <= cel.CreatedTimestamp AND @CreatedDateEndDate >= cel.CreatedTimestamp))
AND (@CompanyName IS NULL OR CompanyName LIKE @CompanyName)

AND (@SalesTrackingCode1Code IS NULL OR [stc1].Code IN (SELECT DATA FROM dbo.Split(@SalesTrackingCode1Code,',')))
AND (@SalesTrackingCode2Code IS NULL OR [stc2].Code IN (SELECT DATA FROM dbo.Split(@SalesTrackingCode2Code,',')))
AND (@SalesTrackingCode3Code IS NULL OR [stc3].Code IN (SELECT DATA FROM dbo.Split(@SalesTrackingCode3Code,',')))
AND (@SalesTrackingCode4Code IS NULL OR [stc4].Code IN (SELECT DATA FROM dbo.Split(@SalesTrackingCode4Code,',')))
AND (@SalesTrackingCode5Code IS NULL OR [stc5].Code IN (SELECT DATA FROM dbo.Split(@SalesTrackingCode5Code,',')))
)
SELECT * FROM FilteredContent
--toEmail is built-up so putting the filter right at the end:
WHERE
(@ToEmail IS NULL OR ToEmail LIKE @ToEmail)

GO

