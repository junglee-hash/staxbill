
CREATE PROCEDURE [dbo].[usp_GetCustomerHierarchy]
	@CustomerId BIGINT
AS

--Get account id to convince SQL Server to have a better query plan
DECLARE @AccountId BIGINT
SELECT @AccountId = AccountId FROM Customer WHERE Id = @CustomerId

DECLARE @Hierarchy AS TABLE
(
    CustomerId BIGINT NOT NULL
    ,ParentId BIGINT NULL
    ,Level INT NOT NULL
    ,Relation TINYINT NOT NULL
)

-- Relation is enum in code:
	-- 1 == Me
	-- 2 == Ancestor
	-- 3 == Descendent
 

--Find all children to the specified customer
;WITH Children AS
  (
    SELECT     Id, ParentId, 0 as Level
    FROM       Customer
    WHERE      Id = @CustomerId AND IsDeleted = 0
    UNION ALL
    SELECT     si.Id, si.ParentId, Level + 1 as Level
    FROM       Customer si
    INNER JOIN Children
            ON Children.ParentId = si.Id
	WHERE si.IsDeleted = 0
		AND si.AccountId = @AccountId
  )
INSERT INTO @Hierarchy
SELECT Id as CustomerId, ParentId, Level,CASE WHEN Level = 0 THEN 1 ELSE 2 END as Relation FROM Children

 

--Find all parents to the specified customer
;WITH Parents AS
  (
    SELECT     Id, ParentId, 0 as Level
    FROM       Customer
    WHERE      Id = @CustomerId AND IsDeleted = 0
    UNION ALL
    SELECT     si.Id, si.ParentId, Level + 1 as Level
    FROM       Customer si
    INNER JOIN Parents
            ON Parents.Id = si.ParentId
	WHERE si.IsDeleted = 0
		AND si.AccountId = @AccountId
  )
INSERT INTO @Hierarchy
SELECT Id as CustomerId, ParentId, Level,3 as Relation
FROM Parents
WHERE Id != @CustomerId --Already in the table

 

SELECT 
    CustomerId
    ,ParentId 
    ,Level
    ,Relation
FROM @Hierarchy

GO

