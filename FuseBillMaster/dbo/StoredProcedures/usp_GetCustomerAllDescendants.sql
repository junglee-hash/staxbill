

CREATE   PROCEDURE [dbo].[usp_GetCustomerAllDescendants]
	 @ParentCustomerId int,

	 --Paging variables
	 @SortOrder NVARCHAR(255),
	 @SortExpression NVARCHAR(255) ,
	 @PageNumber BIGINT,
	 @PageSize BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	WITH cte AS (
	SELECT Id FROM dbo.AllCustomerDescendants(@ParentCustomerId)
	)
	SELECT * from cte
	order by 
		case when @SortOrder = 'Acsending' and @SortExpression = 'customerId' then Id end asc,
		case when @SortOrder = 'Descending' and @SortExpression = 'customerId' then Id end desc
	OFFSET (@PageNumber * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
	
END

GO

