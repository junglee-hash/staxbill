
CREATE VIEW [dbo].[vw_AccountEmailSummary]
AS
SELECT 
	a.Id
	, a.AccountId
	, a.Enabled
	, e.Name AS EmailType
	, e.Description as EmailDescription
	, e.SortOrder as EmailSortOrder
	, ect.Name As EmailCategory
	, ect.Description as EmailCategoryDescription
	, ect.SortOrder as EmailCategorySortOrder
FROM     dbo.AccountEmailTemplate AS a 
INNER JOIN Lookup.EmailCategory AS ect ON  ect.id = a.EmailCategoryId
INNER JOIN Lookup.EmailTemplateType AS e ON e.Id = a.TypeId

GO

