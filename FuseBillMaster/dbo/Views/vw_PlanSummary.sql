

CREATE   VIEW [dbo].[vw_PlanSummary]
AS
WITH CurrentPlanVersion AS (SELECT     MAX(Id) AS Id, PlanId
                                                                FROM          dbo.PlanRevision
                                                                GROUP BY PlanId), CountofActiveSubscriptions AS
    (SELECT     COUNT(*) AS Count, pr.PlanId
      FROM          dbo.Subscription AS s INNER JOIN
                             dbo.PlanFrequency AS ip ON s.PlanFrequencyId = ip.Id INNER JOIN
                             dbo.PlanRevision AS pr ON ip.PlanRevisionId = pr.Id
      GROUP BY pr.PlanId)
    SELECT     p.AccountId, p.Code AS PlanCode, p.Name, p.Reference, p.Description, p.StatusId, ISNULL(coas.Count, 0) AS Subscriptions, pr.Id AS PlanRevisionId, p.Id
     FROM         dbo.[Plan] AS p INNER JOIN
                            CurrentPlanVersion AS pv ON p.Id = pv.PlanId INNER JOIN
                            dbo.PlanRevision AS pr ON p.Id = pr.PlanId AND pr.Id = pv.Id LEFT OUTER JOIN
                            CountofActiveSubscriptions AS coas ON p.Id = coas.PlanId
	WHERE p.IsDeleted = 0

GO

EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_PlanSummary';


GO

EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[14] 2[27] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "p"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 218
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "pv"
            Begin Extent = 
               Top = 6
               Left = 473
               Bottom = 95
               Right = 633
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "pr"
            Begin Extent = 
               Top = 6
               Left = 256
               Bottom = 125
               Right = 435
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "coas"
            Begin Extent = 
               Top = 6
               Left = 671
               Bottom = 95
               Right = 831
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_PlanSummary';


GO

