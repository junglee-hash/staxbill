
CREATE VIEW [dbo].[vw_TextLogSummary]
AS
SELECT 
	ctl.[Id]
	, ctl.[CustomerId]
	, ctl.[Body]
	, ctl.[PhoneNumber]
	, ctl.[TxtTypeId]
	, ctl.[TxtStatusId]
	, ctl.[Result]
	, ctl.[CreatedTimestamp]
	, ctl.[SentTimestamp]
	, ctl.[ModifiedTimestamp]
	, ctl.TwilioMessagingSid
	, c.FirstName AS CustomerFirstName
	, c.LastName AS CustomerLastName
	, c.Reference AS CustomerReference
	, c.ParentId AS CustomerParentId
	, c.CompanyName AS CompanyName
	, a.Id AS AccountId
	, a.CompanyName AS AccountCompanyName
FROM CustomerTextLog ctl
INNER JOIN Customer c ON ctl.CustomerId = c.Id
INNER JOIN Account a ON a.Id = c.AccountId

GO

