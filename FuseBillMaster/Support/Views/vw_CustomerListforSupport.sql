CREATE VIEW [Support].[vw_CustomerListforSupport]
AS
SELECT        c.Id AS CustomerId, c.FirstName, c.MiddleName, c.LastName, c.PrimaryEmail, c.PrimaryPhone, c.SecondaryEmail, c.SecondaryPhone, c.Reference, c.AccountId, CONVERT(smallDateTime, 
                         dbo.fn_GetTimezoneTime(c.CreatedTimestamp, ap.TimezoneId)) AS CustomerCreatedTimestamp
						 , CONVERT(smallDateTime, 
                         dbo.fn_GetTimezoneTime(c.ActivationTimestamp, ap.TimezoneId)) AS CustomerActivatedTimestamp, CONVERT(smallDateTime, dbo.fn_GetTimezoneTime(c.CancellationTimestamp, ap.TimezoneId)) AS CustomerCancelledTimestamp, c.CompanyName, 
                         c.MonthlyRecurringRevenue, c.NetMRR, c.ArBalance, c.NextBillingDate, lcs.Name AS CustomerStatus, cas.Name AS CustomerAccountingStatus, lcu.IsoName AS Currency, s.PlanName AS PlanName, 
                         li.Name AS SubscriptionInterval, s.NumberOfIntervals, lss.Name AS SubscriptionStatus
						 , dbo.fn_GetTimezoneTime(bp.EndDate , ap.TimezoneId) AS SubscriptionRechargeTimestamp
FROM            dbo.Customer AS c INNER JOIN
                         Lookup.CustomerStatus AS lcs WITH (nolock)  ON c.StatusId = lcs.Id INNER JOIN
                         Lookup.CustomerAccountStatus AS cas WITH (nolock)  ON c.AccountStatusId = cas.Id INNER JOIN
                         Lookup.Currency AS lcu WITH (nolock)  ON c.CurrencyId = lcu.Id INNER JOIN
                         dbo.AccountPreference AS ap WITH (nolock)  ON c.AccountId = ap.Id LEFT OUTER JOIN
                         dbo.Subscription AS s WITH (nolock)  ON c.Id = s.CustomerId LEFT OUTER JOIN
						 dbo.billingperiod AS bp WITH (nolock)  ON s.BillingPeriodDefinitionId = bp.BillingPeriodDefinitionId and bp.PeriodStatusId = 1 LEFT OUTER JOIN
                         Lookup.Interval AS li WITH (nolock)  ON s.IntervalId = li.Id LEFT OUTER JOIN
                         Lookup.SubscriptionStatus AS lss WITH (nolock)  ON s.StatusId = lss.Id

GO

