CREATE PROCEDURE [dbo].[usp_FindSubscriptionProductByDifferentFields]
	@AccountId bigint,
	@Subscriptions varchar(max),
	@SubscriptionProductTypes nvarchar(max),
	@SubscriptionProductValues nvarchar(max)
AS
BEGIN

	SET NOCOUNT ON;

	 --DECLARE @CustomerValues nvarchar(max) = '1-55|2-Create a plan with a lot of products and subscribe a customer to it'
	 --DECLARE @AccountId bigint = 7

-- Stores the RecordId and which customer it belongs to
declare @subscriptionIds table
(
AccountUploadRecordId bigint,
SubscriptionId bigint
)

-- Stores the RecordId and which field to match on
declare @subscriptionProductFinalTypes table
(
AccountUploadRecordId bigint,
EntityType tinyint
)
-- Stores the RecordId and the value to match on
declare @subscriptionProductFinalValues table
(
AccountUploadRecordId bigint,
EntityValue nvarchar(1000)
)
-- Stores the combo of the above two tables
declare @subscriptionProductData table
(
AccountUploadRecordId bigint NOT NULL,
SubscriptionId bigint NOT NULL,
EntityType tinyint NOT NULL,
EntityValue nvarchar(1000) NOT NULL
)

INSERT INTO @subscriptionIds (AccountUploadRecordId, SubscriptionId)
SELECT 
		
		(SELECT Data FROM dbo.Split(Result.Data, '-') WHERE Id = 1 ) as EntityType
		, (SELECT Data
			FROM dbo.Split(Result.Data, '-') WHERE Id = 2 ) as EntityValue
	FROM (
		SELECT Data
		FROM dbo.Split(@Subscriptions, '|')
	) as Result

INSERT INTO @subscriptionProductFinalTypes (AccountUploadRecordId, EntityType)
SELECT 
		
		(SELECT Data FROM dbo.Split(Result.Data, '-') WHERE Id = 1 ) as EntityType
		, (SELECT 
				REPLACE(REPLACE(Data, '_____', '-'), '^^^^^', '|') --UNDO the split character replace done before calling sproc
			FROM dbo.Split(Result.Data, '-') WHERE Id = 2 ) as EntityValue
	FROM (
		SELECT Data
		FROM dbo.Split(@SubscriptionProductTypes, '|')
	) as Result

INSERT INTO @subscriptionProductFinalValues (AccountUploadRecordId, EntityValue)
SELECT 
		
		(SELECT Data FROM dbo.Split(Result.Data, '-') WHERE Id = 1 ) as EntityType
		, (SELECT 
				REPLACE(REPLACE(Data, '_____', '-'), '^^^^^', '|') --UNDO the split character replace done before calling sproc
			FROM dbo.Split(Result.Data, '-') WHERE Id = 2 ) as EntityValue
	FROM (
		SELECT Data
		FROM dbo.Split(@SubscriptionProductValues, '|')
	) as Result


INSERT INTO @subscriptionProductData
SELECT t.AccountUploadRecordId, s.SubscriptionId, t.EntityType, v.EntityValue
FROM @subscriptionProductFinalTypes t
INNER JOIN @subscriptionProductFinalValues v ON v.AccountUploadRecordId = t.AccountUploadRecordId
INNER JOIN @subscriptionIds s ON s.AccountUploadRecordId = t.AccountUploadRecordId

SELECT 
	sd.AccountUploadRecordId
	, sd.EntityType
	, sd.EntityValue
	, ROW_NUMBER() OVER(PARTITION BY sd.EntityType, sd.EntityValue ORDER BY sp.Id) AS [RowNumber]
	, sp.Id
FROM @subscriptionProductData sd
LEFT JOIN SubscriptionProduct sp
LEFT JOIN SubscriptionProductOverride spo ON sp.Id = spo.Id
LEFT JOIN Subscription s ON s.Id = sp.SubscriptionId
LEFT JOIN Customer c ON c.Id = s.CustomerId
ON CASE 
		WHEN sd.EntityType = 1 THEN
            CASE
                WHEN sp.Id = sd.EntityValue THEN 1
                ELSE 0
            END
		WHEN sd.EntityType = 2 AND sp.PlanProductCode = sd.EntityValue THEN 1
		WHEN sd.EntityType = 3 AND COALESCE(spo.Name, sp.PlanProductName) = sd.EntityValue THEN 1
		WHEN sd.EntityType = 4 AND COALESCE(spo.Description, sp.PlanProductDescription) = sd.EntityValue THEN 1
		ELSE 0 END
	= 1 AND c.AccountId = @AccountId
			AND sp.SubscriptionId = sd.SubscriptionId -- Lock to subscription

END

GO

