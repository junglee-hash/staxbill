
CREATE VIEW [dbo].[vw_TaxRuleSummary]
AS
SELECT tr.Id, tr.AccountId, tr.Name, tr.Percentage, tr.RegistrationCode, c.Name as CountryName, s.Name as StateName
FROM TaxRule tr
INNER JOIN Lookup.Country c ON c.Id = tr.CountryId
LEFT JOIN Lookup.State s ON s.Id = tr.StateId

GO

