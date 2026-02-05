CREATE PROCEDURE [dbo].[usp_FindSubscriptionByDifferentFields]
	@AccountId bigint,
	@Customers varchar(max),
	@SubscriptionTypes nvarchar(max),
	@SubscriptionValues nvarchar(max)
AS
BEGIN

	SET NOCOUNT ON;

	 --DECLARE @CustomerValues nvarchar(max) = '1-55|2-Create a plan with a lot of products and subscribe a customer to it'
	 --DECLARE @AccountId bigint = 7

-- Stores the RecordId and which customer it belongs to
declare @customerIds table
(
AccountUploadRecordId bigint,
CustomerId bigint
)

-- Stores the RecordId and which field to match on
declare @subscriptionFinalTypes table
(
AccountUploadRecordId bigint,
EntityType tinyint
)
-- Stores the RecordId and the value to match on
declare @subscriptionFinalValues table
(
AccountUploadRecordId bigint,
EntityValue nvarchar(1000)
)
-- Stores the combo of the above two tables
declare @subscriptionData table
(
AccountUploadRecordId bigint NOT NULL,
CustomerId bigint NOT NULL,
EntityType tinyint NOT NULL,
EntityValue nvarchar(1000) NOT NULL
)

INSERT INTO @customerIds (AccountUploadRecordId, CustomerId)
SELECT 
		
		(SELECT Data FROM dbo.Split(Result.Data, '-') WHERE Id = 1 ) as EntityType
		, (SELECT Data
			FROM dbo.Split(Result.Data, '-') WHERE Id = 2 ) as EntityValue
	FROM (
		SELECT Data
		FROM dbo.Split(@Customers, '|')
	) as Result

INSERT INTO @subscriptionFinalTypes (AccountUploadRecordId, EntityType)
SELECT 
		
		(SELECT Data FROM dbo.Split(Result.Data, '-') WHERE Id = 1 ) as EntityType
		, (SELECT 
				REPLACE(REPLACE(Data, '_____', '-'), '^^^^^', '|') --UNDO the split character replace done before calling sproc
			FROM dbo.Split(Result.Data, '-') WHERE Id = 2 ) as EntityValue
	FROM (
		SELECT Data
		FROM dbo.Split(@SubscriptionTypes, '|')
	) as Result

INSERT INTO @subscriptionFinalValues (AccountUploadRecordId, EntityValue)
SELECT 
		
		(SELECT Data FROM dbo.Split(Result.Data, '-') WHERE Id = 1 ) as EntityType
		, (SELECT 
				REPLACE(REPLACE(Data, '_____', '-'), '^^^^^', '|') --UNDO the split character replace done before calling sproc
			FROM dbo.Split(Result.Data, '-') WHERE Id = 2 ) as EntityValue
	FROM (
		SELECT Data
		FROM dbo.Split(@SubscriptionValues, '|')
	) as Result


INSERT INTO @subscriptionData
SELECT t.AccountUploadRecordId, c.CustomerId, t.EntityType, v.EntityValue
FROM @subscriptionFinalTypes t
INNER JOIN @subscriptionFinalValues v ON v.AccountUploadRecordId = t.AccountUploadRecordId
INNER JOIN @customerIds c ON c.AccountUploadRecordId = t.AccountUploadRecordId

SELECT 
	sd.AccountUploadRecordId
	, sd.EntityType
	, sd.EntityValue
	, ROW_NUMBER() OVER(PARTITION BY sd.EntityType, sd.EntityValue ORDER BY s.Id) AS [RowNumber]
	, s.Id
FROM @subscriptionData sd
LEFT JOIN Subscription s
LEFT JOIN SubscriptionOverride so ON s.Id = so.Id
LEFT JOIN Customer c ON c.Id = s.CustomerId
ON CASE 
		WHEN sd.EntityType = 1 THEN
            CASE
                WHEN s.Id = sd.EntityValue THEN 1
                ELSE 0
            END
		WHEN sd.EntityType = 2 AND s.PlanCode = sd.EntityValue THEN 1
		WHEN sd.EntityType = 3 AND COALESCE(so.Name, s.PlanName) = sd.EntityValue THEN 1
		WHEN sd.EntityType = 4 AND COALESCE(so.Description, s.PlanDescription) = sd.EntityValue THEN 1
		WHEN sd.EntityType = 5 AND s.Reference = sd.EntityValue THEN 1
		ELSE 0 END
	= 1 AND c.AccountId = @AccountId
			AND s.CustomerId = sd.CustomerId -- Lock to customer

END

GO

