
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [dbo].[usp_NonCompatibleSalesforcePlans]
	@AccountId bigint
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [Plan]
		SET SalesforceCompatible = 1
	WHERE AccountId = @AccountId

    SELECT 
		p.*
		, p.StatusId as [Status]
	FROM [Plan] p
	INNER JOIN [PlanRevision] pr ON p.Id = pr.PlanId
		AND pr.IsActive = 1
	INNER JOIN [PlanProduct] pp ON pr.Id = pp.PlanRevisionId
		AND pp.StatusId = 1
	INNER JOIN [Product] prod ON prod.Id = pp.ProductId
	WHERE p.AccountId = @AccountId
		AND p.StatusId = 1
	GROUP BY prod.Id, p.[Id], p.[AccountId], p.[ModifiedTimestamp], p.[CreatedTimestamp], p.[Code], p.[Name], p.[Description], p.[StatusId], p.[LongDescription], p.[Reference], p.[AutoApplyChanges], p.[SalesforceCompatible], p.[IsDeleted]
	HAVING COUNT(prod.Id) > 1 AND p.IsDeleted = 0
END

GO

