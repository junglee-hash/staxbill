CREATE PROCEDURE [dbo].[usp_CustomerArBalance]
   @CustomerId BIGINT
	,@StartDate DATETIME = NULL
	,@EndDate DATETIME
	,@ShowChildData BIT
	,@ShowParentData BIT
AS

DECLARE @AccountId BIGINT
	,@CurrencyId INT
	,@CustomerIds as IDList

SELECT @AccountId = AccountId
	,@CurrencyId = CurrencyId
FROM Customer
WHERE Id = @CustomerId

INSERT INTO @CustomerIds
SELECT Id FROM Customer
WHERE (@ShowParentData = 1 AND Id = @CustomerId)
	OR (@ShowChildData = 1 AND Id IN (SELECT Id FROM Customer WHERE ParentId = @CustomerId AND AccountId = @AccountId))

--Testing
--SELECT 
--	* 
--FROM tvf_CustomerLedgers(@AccountId, @CurrencyId, @StartDate, @EndDate)
--WHERE (@ShowParentData = 1 AND CustomerId = @CustomerId)
--	OR (@ShowChildData = 1 AND CustomerId IN (SELECT Id FROM Customer WHERE ParentId = @CustomerId AND AccountId = @AccountId))

SELECT 
	COALESCE(SUM(ArDebit),0) as ArDebit
	,COALESCE(SUM(ArCredit),0)  as ArCredit
FROM tvf_CustomerLedgers(@AccountId, @CurrencyId, @StartDate, @EndDate, @CustomerIds)

GO

