CREATE PROCEDURE [Reporting].[GetAllCustomerNotes]
	@AccountId BIGINT,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL
AS

SELECT
	c.Id as FusebillId,
	c.Reference as CustomerId,
	c.FirstName + ' ' + c.LastName as CustomerName,
	c.CompanyName,
	dbo.fn_GetTimezoneTime(cn.CreatedTimestamp,ap.TimezoneId) as CreatedTimestamp,
	COALESCE(u.FirstName,'') + ' ' + COALESCE(u.LastName,'') + ' (' + COALESCE(u.Email,'') + ')' as [UserName],
	cn.Note
FROM CustomerNote cn
	INNER JOIN Customer c ON c.Id = cn.CustomerId
	INNER JOIN AccountPreference ap ON ap.Id = c.AccountId
	LEFT JOIN [User] u ON u.Id = cn.UserId
WHERE c.AccountId = @AccountId
	AND (@StartDate IS NULL OR cn.CreatedTimestamp >= @StartDate)
	AND (@EndDate IS NULL OR cn.CreatedTimestamp <= @EndDate);

GO

