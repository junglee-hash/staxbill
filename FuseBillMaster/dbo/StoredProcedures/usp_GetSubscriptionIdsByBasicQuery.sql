CREATE   PROCEDURE [dbo].[usp_GetSubscriptionIdsByBasicQuery]
@AccountId BIGINT,
@SortOrder NVARCHAR(255),
@PageNumber BIGINT,
@PageSize BIGINT,
@SubscriptionStatus VARCHAR(255) = NULL,
@SubscriptionReference NVARCHAR(255) = NULL
WITH RECOMPILE
AS

SET NOCOUNT ON

declare @statuses table
(
Id int
)

INSERT INTO @statuses (Id)
select Data from dbo.Split (@SubscriptionStatus,',')

SELECT s.Id
	FROM dbo.Subscription s 
	WHERE s.IsDeleted = 0
		AND s.AccountId = @AccountId
		AND (@SubscriptionReference IS NULL OR Reference LIKE  @SubscriptionReference OR (@SubscriptionReference = '[empty]' AND Reference IS NULL))
		AND (@SubscriptionStatus IS NULL OR StatusId IN (SELECT Id FROM @statuses))
	ORDER BY 
		CASE When @SortOrder = 'Ascending' THEN ID END ASC,
		CASE When @SortOrder = 'Descending' THEN ID END DESC
		OFFSET (@PageNumber * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY



SET NOCOUNT OFF

GO

