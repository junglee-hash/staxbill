
CREATE VIEW [dbo].[vw_SubscriptionCountByPlanFrequency]
AS
SELECT     TOP (100) PERCENT pf.Id, p.AccountId, COUNT(s.Id) AS NumberOfSubscriptions
FROM         dbo.[Plan] AS p INNER JOIN
                      dbo.PlanRevision AS pr ON p.Id = pr.PlanId INNER JOIN
                      dbo.PlanFrequency AS pf ON pr.Id = pf.PlanRevisionId LEFT OUTER JOIN
                      dbo.Subscription AS s ON pf.Id = s.PlanFrequencyId
GROUP BY pf.Id, p.AccountId

GO

