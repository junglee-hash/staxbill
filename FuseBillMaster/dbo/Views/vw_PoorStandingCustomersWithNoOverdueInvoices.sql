
CREATE VIEW [dbo].[vw_PoorStandingCustomersWithNoOverdueInvoices]
AS
WITH OverdueInvoiceCount AS (SELECT COUNT(i.Id) AS OverdueCount, i.CustomerId
                            FROM     dbo.Invoice AS i INNER JOIN
                                                dbo.PaymentSchedule AS ps ON i.Id = ps.InvoiceId INNER JOIN
                                                dbo.PaymentScheduleJournal AS psj ON ps.Id = psj.PaymentScheduleId AND psj.StatusId = 3 AND psj.IsActive = 1 
                            GROUP BY i.CustomerId)
    SELECT c.Id, c.AccountId, c.ArBalance, c.AccountStatusId, c.StatusId
    FROM     dbo.Customer AS c INNER JOIN
                      dbo.CustomerBillingSetting AS cbs ON c.Id = cbs.Id AND cbs.AutoCollect IS NULL LEFT JOIN
                      OverdueInvoiceCount AS oic ON c.Id = oic.CustomerId
    WHERE  (c.AccountStatusId = 2) AND oic.CustomerId IS NULL

GO

