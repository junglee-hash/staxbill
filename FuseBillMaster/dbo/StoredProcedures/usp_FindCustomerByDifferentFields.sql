CREATE PROCEDURE [dbo].[usp_FindCustomerByDifferentFields]
	@AccountId bigint,
	@CustomerTypes nvarchar(max),
	@CustomerValues nvarchar(max)
AS
BEGIN

	SET NOCOUNT ON;

	 --DECLARE @CustomerValues nvarchar(max) = '1-55|2-Create a plan with a lot of products and subscribe a customer to it'
	 --DECLARE @AccountId bigint = 7

-- Stores the RecordId and which field to match on
declare @customerFinalTypes table
(
AccountUploadRecordId bigint,
EntityType tinyint
)
-- Stores the RecordId and the value to match on
declare @customerFinalValues table
(
AccountUploadRecordId bigint,
EntityValue nvarchar(1000)
)
-- Stores the combo of the above two tables
declare @customerData table
(
AccountUploadRecordId bigint NOT NULL,
EntityType tinyint NOT NULL,
EntityValue nvarchar(1000) NOT NULL
)

INSERT INTO @customerFinalTypes (AccountUploadRecordId, EntityType)
SELECT 
		
		(SELECT Data FROM dbo.Split(Result.Data, '-') WHERE Id = 1 ) as EntityType
		, (SELECT 
				REPLACE(REPLACE(Data, '_____', '-'), '^^^^^', '|') --UNDO the split character replace done before calling sproc
			FROM dbo.Split(Result.Data, '-') WHERE Id = 2 ) as EntityValue
	FROM (
		SELECT Data
		FROM dbo.Split(@CustomerTypes, '|')
	) as Result

INSERT INTO @customerFinalValues (AccountUploadRecordId, EntityValue)
SELECT 
		
		(SELECT Data FROM dbo.Split(Result.Data, '-') WHERE Id = 1 ) as EntityType
		, (SELECT 
				REPLACE(REPLACE(Data, '_____', '-'), '^^^^^', '|') --UNDO the split character replace done before calling sproc
			FROM dbo.Split(Result.Data, '-') WHERE Id = 2 ) as EntityValue
	FROM (
		SELECT Data
		FROM dbo.Split(@CustomerValues, '|')
	) as Result


INSERT INTO @customerData
SELECT t.AccountUploadRecordId, t.EntityType, v.EntityValue
FROM @customerFinalTypes t
INNER JOIN @customerFinalValues v ON v.AccountUploadRecordId = t.AccountUploadRecordId

SELECT 
	cd.AccountUploadRecordId
	, cd.EntityType
	, cd.EntityValue
	, ROW_NUMBER() OVER(PARTITION BY cd.EntityType, cd.EntityValue ORDER BY c.Id) AS [RowNumber]
	, c.Id
	, c.StatusId
FROM @customerData cd
LEFT JOIN Customer c
ON CASE 
		WHEN cd.EntityType = 1 AND c.Id = cd.EntityValue THEN 1
		-- Some exports use CustomerId and some use Reference as the field name but both match to reference
		WHEN (cd.EntityType = 2 OR cd.EntityType = 5) AND c.Reference = cd.EntityValue THEN 1
		WHEN cd.EntityType = 3 AND c.CompanyName = cd.EntityValue THEN 1
		WHEN cd.EntityType = 4 AND c.PrimaryEmail = cd.EntityValue THEN 1
		ELSE 0 END
	= 1 AND c.AccountId = @AccountId

END

GO

