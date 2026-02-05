
CREATE VIEW [dbo].[vw_PlanProductSummary]
AS
WITH CurrentPlanVersion AS (SELECT MAX(Id) AS Id, PlanId
                                                            FROM     dbo.PlanRevision
                                                            GROUP BY PlanId)
    SELECT TOP (100) PERCENT pp.Id, pp.PlanProductUniqueId, 
		pv.PlanId, pp.PlanRevisionId, pp.IsOptional, pp.IsIncludedByDefault, 
		pp.Quantity, pp.IsTrackingItems, pp.Code, pp.Name, 
		p.ProductTypeId, pt.SortOrder, p.AccountId, 
                      pp.StatusId, pp.ProductId
    FROM     dbo.PlanProduct AS pp INNER JOIN
                      CurrentPlanVersion AS pv ON pp.PlanRevisionId = pv.Id INNER JOIN
                      dbo.Product AS p ON p.Id = pp.ProductId INNER JOIN
                      Lookup.ProductType AS pt ON pt.Id = p.ProductTypeId

GO

