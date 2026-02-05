
CREATE procedure [Reporting].[Inyo_DiscountsByCustomer]   
--	declare
	@AccountId BIGINT 
	,@StartDate DATETIME 
	,@EndDate DATETIME 
AS

set transaction isolation level snapshot
set nocount on
declare @TimezoneId int

select @TimezoneId = TimezoneId
from AccountPreference where Id = @AccountId 

select 
	@StartDate = dbo.fn_GetUtcTime(@StartDate,TimezoneId)
	,@EndDate = dbo.fn_GetUtcTime(@EndDate,TimezoneId)
from 
	AccountPreference 
where 
	Id = @AccountId 

SELECT
	c.Id as [Fusebill Id],
	ISNULL(c.Reference,'') as [Customer Id],
	ISNULL(c.FirstName,'') as [First Name],
	ISNULL(c.LastName,'') as [Last Name],
	ISNULL(c.CompanyName,'') as [Company Name],
	ISNULL(dt.Description,'') as [Discount Name],
	SUM(dt.Amount) as [Total Discounted]
FROM Discount d
INNER JOIN [Transaction] dt ON dt.Id = d.Id
INNER JOIN Customer c on dt.CustomerId = c.Id
WHERE dt.AccountId = @AccountId
	AND dt.EffectiveTimestamp >= @StartDate
	AND dt.EffectiveTimestamp < @EndDate
Group by
c.Id, c.Reference, c.FirstName, c.LastName, c.CompanyName, dt.Description

GO

