

CREATE     PROCEDURE [dbo].[usp_UpsertAccountGeotabDevicePlan]
	@AccountId BIGINT,
	@Name NVARCHAR(255),	
	@PlanId INT,	
	@Level INT,	
	@ValidForOrder BIT,
	@IsThirdPartyDevice BIT
AS
BEGIN

	CREATE TABLE #Plan
	(
		[AccountId] BIGINT NOT NULL,
		[Name] NVARCHAR(255) NOT NULL,	
		[PlanId] INT NULL,	
		[Level] INT NULL,	
		[ValidForOrder] BIT NULL,
		[IsThirdPartyDevice] BIT NOT NULL
	);
	INSERT INTO #Plan
	VALUES (@AccountId, @Name, @PlanId, @Level, @ValidForOrder, @IsThirdPartyDevice)
	
	MERGE AccountGeotabDevicePlan AS TARGET
	USING #Plan AS SOURCE
	ON 
	(
		@IsThirdPartyDevice = 0
		AND SOURCE.AccountId = TARGET.AccountId
		AND SOURCE.PlanId = TARGET.PlanId
		AND TARGET.[IsThirdPartyDevice] = 0
	)
	OR
	(
		 @IsThirdPartyDevice = 1
		 AND SOURCE.AccountId = TARGET.AccountId
		 AND Source.[Name] = TARGET.[Name]
		 AND TARGET.[IsThirdPartyDevice] = 1
	)

    WHEN NOT MATCHED BY TARGET THEN
        INSERT (AccountId ,[Name], PlanId, [Level], ValidForOrder, IsThirdPartyDevice ) 
        VALUES (SOURCE.AccountId, SOURCE.[Name], SOURCE.PlanId, SOURCE.[Level], SOURCE.ValidForOrder, Source.IsThirdPartyDevice)

    WHEN MATCHED THEN UPDATE SET
        TARGET.[Name] = SOURCE.[Name],
        TARGET.[Level]	= SOURCE.[Level],
		TARGET.ValidForOrder = SOURCE.ValidForOrder;

	DROP TABLE #Plan

END

GO

