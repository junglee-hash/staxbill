

CREATE   VIEW [dbo].[vw_CashReportDetail]
AS
SELECT c.AccountId, paj.EffectiveTimestamp, COALESCE (tp.Id, tr.Id) AS TransactionId, c.Id AS FusebillId, ISNULL(c.Reference, '') AS CustomerId, CASE WHEN Title.Name IS NULL 
               THEN '' ELSE Title.Name + ' ' END + CASE WHEN c.FirstName IS NULL THEN '' ELSE c.FirstName + ' ' END + CASE WHEN c.MiddleName IS NULL 
               THEN '' ELSE c.MiddleName + ' ' END + CASE WHEN c.LastName IS NULL THEN '' ELSE c.LastName + ' ' END AS CustomerName, ISNULL(c.CompanyName, '') AS CompanyName, 
               COALESCE (p.Reference, r.Reference, '') AS PaymentReference, ps.Name AS Source, COALESCE (ttp.Name, ttr.Name) AS Type, pm.Name AS PaymentMethod, 
               COALESCE (tp.Amount, - tr.Amount) AS Amount, c.CurrencyId AS Currency
FROM  dbo.PaymentActivityJournal AS paj LEFT OUTER JOIN
               dbo.Payment AS p ON paj.Id = p.PaymentActivityJournalId LEFT OUTER JOIN
               dbo.Refund AS r ON paj.Id = r.PaymentActivityJournalId INNER JOIN
               Lookup.PaymentSource AS ps ON paj.PaymentSourceId = ps.Id INNER JOIN
               dbo.Customer AS c ON paj.CustomerId = c.Id LEFT OUTER JOIN
               Lookup.Title AS Title ON c.TitleId = Title.Id LEFT OUTER JOIN
               dbo.[Transaction] AS tp ON p.Id = tp.Id LEFT OUTER JOIN
               Lookup.TransactionType AS ttp ON tp.TransactionTypeId = ttp.Id LEFT OUTER JOIN
               dbo.[Transaction] AS tr ON r.Id = tr.Id LEFT OUTER JOIN
               Lookup.TransactionType AS ttr ON tr.TransactionTypeId = ttr.Id INNER JOIN
               Lookup.PaymentMethodType AS pm ON paj.PaymentMethodTypeId = pm.Id
WHERE paj.PaymentTypeId <> 1 AND paj.PaymentActivityStatusId NOT IN (2,3) -- failed, unknown

GO

EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_CashReportDetail';


GO

EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Begin Table = "tp"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 221
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ttp"
            Begin Extent = 
               Top = 6
               Left = 259
               Bottom = 95
               Right = 419
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "c"
            Begin Extent = 
               Top = 6
               Left = 457
               Bottom = 125
               Right = 655
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Title"
            Begin Extent = 
               Top = 6
               Left = 693
               Bottom = 95
               Right = 853
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "p"
            Begin Extent = 
               Top = 6
               Left = 891
               Bottom = 125
               Right = 1065
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "r"
            Begin Extent = 
               Top = 6
               Left = 1103
               Bottom = 110
               Right = 1280
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "paj"
            Begin Extent = 
               Top = 126
               Left = 48
               Bottom = 269
               Right = 279
            End
            DisplayFlags = 280
            TopColumn = 0
         En', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_CashReportDetail';


GO

EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'd
         Begin Table = "ps"
            Begin Extent = 
               Top = 6
               Left = 1318
               Bottom = 95
               Right = 1478
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "pm"
            Begin Extent = 
               Top = 273
               Left = 48
               Bottom = 380
               Right = 232
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tr"
            Begin Extent = 
               Top = 126
               Left = 327
               Bottom = 269
               Right = 534
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ttr"
            Begin Extent = 
               Top = 98
               Left = 703
               Bottom = 205
               Right = 887
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
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 4176
         Alias = 1980
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_CashReportDetail';


GO

