CREATE PROCEDURE [dbo].[usp_TestDriveUsageReport] AS

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
SET NOCOUNT ON;

BEGIN	

	CREATE TABLE #AccountProfile
	(
		AccountId BIGINT
		,CompanyName NVARCHAR(255)
		,ContactEmail NVARCHAR(255)
		,FirstName NVARCHAR(255)
		,LastName NVARCHAR(255)
		,CreatedTimestamp DateTime
		,CustomerCount bigint
		,CustomerLimit bigint
		,SubscriptionCount bigint
		,SubscriptionLimit bigint
		,UserCount bigint
		,UserLimit bigint
		,InvoiceCount bigint
		,InvoiceLimit bigint
		,EmailCount bigint
		,EmailLimit bigint
	)

	INSERT INTO #AccountProfile
	SELECT
		a.Id as AccountId
		,a.CompanyName as CompanyName
		,a.ContactEmail
		, ''
		, ''
		, a.CreatedTimestamp
		,null
		,null
		,null
		,null
		,null
		,null
		,null
		,null
		,null
		,null
	FROM Account a
	WHERE a.TypeId = 2

	--Customer Count
	;WITH CustomerCount AS (
		SELECT
			c.AccountId
			,COUNT(*) as CustCount
		FROM Customer c  
		INNER JOIN Account a  ON a.Id = c.AccountId
		GROUP BY c.AccountId
	)
	UPDATE ap
	SET ap.CustomerCount = c.CustCount
	FROM #AccountProfile ap
	INNER JOIN CustomerCount c  ON c.AccountId = ap.AccountId

	--Subscription count
	;WITH SubscriptionCount AS (
		SELECT
			c.AccountId
			,COUNT(*) as SubCount
		FROM Subscription s  
		INNER JOIN Customer c  ON c.Id = s.CustomerId
		INNER JOIN Account a  ON a.Id = c.AccountId
		GROUP BY c.AccountId
	)
	UPDATE ap
	SET ap.SubscriptionCount = s.SubCount
	FROM #AccountProfile ap
	INNER JOIN SubscriptionCount s  ON s.AccountId = ap.AccountId

	-- User count
	;WITH UsersCount AS (
		SELECT
			AccountId
			,COUNT(*) as Users
		FROM AccountUser  
		GROUP BY AccountId
	)
	UPDATE ap
	SET ap.UserCount = c.Users
	FROM #AccountProfile ap
	INNER JOIN UsersCount c   ON c.AccountId = ap.AccountId

	-- Invoice count
	;WITH InvoiceCount AS (
		SELECT
			AccountId
			,COUNT(*) as Invoices
		FROM Invoice  
		GROUP BY AccountId
	)
	UPDATE ap
	SET ap.InvoiceCount = c.Invoices
	FROM #AccountProfile ap
	INNER JOIN InvoiceCount c   ON c.AccountId = ap.AccountId

	-- Email Count
	;WITH EmailCount AS (
		SELECT
			c.AccountId
			,COUNT(*) as Emails
		FROM CustomerEmailLog cel  
		INNER JOIN Customer c  ON c.Id = cel.CustomerId
		INNER JOIN Account a  ON a.Id = c.AccountId
		GROUP BY c.AccountId
	)
	UPDATE ap
	SET ap.EmailCount = c.Emails
	FROM #AccountProfile ap
	INNER JOIN EmailCount c   ON c.AccountId = ap.AccountId

	-- Customer Limit
	;WITH CustomerLimit AS (
		SELECT
			al.AccountId
			,al.Limit as Limit
		FROM AccountLimit al  
		INNER JOIN Account a  ON a.Id = al.AccountId
		where al.EntityTypeId = 3 --Customer entity type
	)
	UPDATE ap
	SET ap.CustomerLimit = c.Limit
	FROM #AccountProfile ap
	INNER JOIN CustomerLimit c  ON c.AccountId = ap.AccountId

	--Subscription Limit
	;WITH SubscriptionLimit AS (
		SELECT
			al.AccountId
			,al.Limit as Limit
		FROM AccountLimit al  
		INNER JOIN Account a  ON a.Id = al.AccountId
		where al.EntityTypeId = 7 --subscription entity type
	)
	UPDATE ap
	SET ap.SubscriptionLimit = c.Limit
	FROM #AccountProfile ap
	INNER JOIN SubscriptionLimit c  ON c.AccountId = ap.AccountId

	--User Limit
	;WITH UserLimit AS (
		SELECT
			al.AccountId
			,al.Limit as Limit
		FROM AccountLimit al  
		INNER JOIN Account a  ON a.Id = al.AccountId
		where al.EntityTypeId = 2 --user entity type
	)
	UPDATE ap
	SET ap.UserLimit = c.Limit
	FROM #AccountProfile ap
	INNER JOIN UserLimit c  ON c.AccountId = ap.AccountId

	--Invoice Limit
	;WITH InvoiceLimit AS (
		SELECT
			al.AccountId
			,al.Limit as Limit
		FROM AccountLimit al  
		INNER JOIN Account a  ON a.Id = al.AccountId
		where al.EntityTypeId = 11 --invoice entity type
	)
	UPDATE ap
	SET ap.InvoiceLimit = c.Limit
	FROM #AccountProfile ap
	INNER JOIN InvoiceLimit c  ON c.AccountId = ap.AccountId
	
	--Email Limit
	;WITH EmailLimit AS (
		SELECT
			al.AccountId
			,al.Limit as Limit
		FROM AccountLimit al  
		INNER JOIN Account a  ON a.Id = al.AccountId
		where al.EntityTypeId = 59 --email entity type
	)
	UPDATE ap
	SET ap.EmailLimit = c.Limit
	FROM #AccountProfile ap
	INNER JOIN EmailLimit c  ON c.AccountId = ap.AccountId

	--User information
	;WITH UserInfo AS (
		SELECT
			au.AccountId,
			u.FirstName as [FirstName],
			u.LastName as [LastName]
		FROM AccountUser au  
		inner join [User] u on u.Id = au.UserId
		INNER JOIN Account a  ON a.Id = au.AccountId
		inner join AccountUserRole aur on aur.AccountUserId = au.Id
		where aur.RoleTypeId = 1
	)
	UPDATE ap
	SET ap.FirstName = c.FirstName, ap.LastName = c.LastName
	FROM #AccountProfile ap
	INNER JOIN UserInfo c  ON c.AccountId = ap.AccountId

	select * from #AccountProfile order by AccountId desc

	DROP TABLE #AccountProfile

END

GO

