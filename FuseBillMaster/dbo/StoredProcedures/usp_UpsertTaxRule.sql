CREATE   PROCEDURE [dbo].[usp_UpsertTaxRule]
	@AccountId BIGINT
    ,@Percentage DECIMAL(10,8)
	,@Name NVARCHAR(60)
	,@Description NVARCHAR(250)
	,@CountryId BIGINT NULL
    ,@StateId BIGINT NULL
    ,@RegistrationCode NVARCHAR(100) NULL
    ,@CreatedTimestamp DATETIME
    ,@StartDate DATETIME NULL
    ,@EndDate DATETIME NULL
    ,@QuickBooksTaxCodeId BIGINT NULL
    ,@QuickBooksTaxRateId BIGINT NULL
    ,@TaxCode NVARCHAR(1000)
    ,@IsRetired bit
    ,@AuditStatusId INT
    ,@SalesTrackingCodeId1 BIGINT NULL
    ,@SalesTrackingCodeId2 BIGINT NULL
    ,@SalesTrackingCodeId3 BIGINT NULL
    ,@SalesTrackingCodeId4 BIGINT NULL
    ,@SalesTrackingCodeId5 BIGINT NULL

AS
	SELECT 
		@AccountId AS AccountId
		,@Name AS [Name]
		,@Description AS [Description]
		,@Percentage AS [Percentage]
		,@CountryId AS CountryId
		,@StateId AS StateId
		,@StartDate AS StartDate
		,@EndDate AS EndDate
	INTO #uniqueParameters

	DECLARE @LastUpdated TABLE (Id BIGINT NULL)

	MERGE dbo.TaxRule AS TARGET
	USING #uniqueParameters AS SOURCE
	ON SOURCE.AccountId = TARGET.AccountId
	AND SOURCE.[Name] = TARGET.[Name]
	AND SOURCE.[Description] = TARGET.[Description]
	AND SOURCE.[Percentage] = TARGET.[Percentage]
	--COALESCE technique is because we want to ensure null equals null:
	AND COALESCE(SOURCE.CountryId,-1) = COALESCE(TARGET.CountryId,-1)
	AND COALESCE(SOURCE.StateId,-1) = COALESCE(TARGET.StateId,-1)
	AND COALESCE(SOURCE.StartDate,-1) = COALESCE(TARGET.StartDate,-1)
	AND COALESCE(SOURCE.EndDate,-1) = COALESCE(TARGET.EndDate,-1)
	WHEN NOT MATCHED BY TARGET THEN
	INSERT (
		AccountId, 
		[Percentage], 
		[Name], 
		[Description], 
		CountryId, 
		StateId, 
		RegistrationCode, 
		CreatedTimestamp, 
		StartDate, 
		EndDate, 
		QuickBooksTaxCodeId, 
		QuickBooksTaxRateId, 
		TaxCode, 
		IsRetired, 
		AuditStatusId, 
		SalesTrackingCodeId1, 
		SalesTrackingCodeId2, 
		SalesTrackingCodeId3, 
		SalesTrackingCodeId4, 
		SalesTrackingCodeId5
	)
	VALUES (
		@AccountId 
		,@Percentage 
		,@Name
		,@Description
		,@CountryId
		,@StateId
		,@RegistrationCode
		,@CreatedTimestamp
		,@StartDate
		,@EndDate
		,@QuickBooksTaxCodeId
		,@QuickBooksTaxRateId
		,@TaxCode
		,@IsRetired
		,@AuditStatusId
		,@SalesTrackingCodeId1
		,@SalesTrackingCodeId2
		,@SalesTrackingCodeId3
		,@SalesTrackingCodeId4
		,@SalesTrackingCodeId5
	)	
	WHEN MATCHED THEN UPDATE SET
    TARGET.RegistrationCode = @RegistrationCode,
	TARGET.CreatedTimestamp = @CreatedTimestamp,
	TARGET.QuickBooksTaxCodeId = @QuickBooksTaxCodeId,
	TARGET.QuickBooksTaxRateId = @QuickBooksTaxRateId, 
	TARGET.TaxCode = @TaxCode, 
	TARGET.IsRetired = @IsRetired, 
	TARGET.AuditStatusId = @AuditStatusId, 
	TARGET.SalesTrackingCodeId1 = @SalesTrackingCodeId1, 
	TARGET.SalesTrackingCodeId2 = @SalesTrackingCodeId2, 
	TARGET.SalesTrackingCodeId3 = @SalesTrackingCodeId3, 
	TARGET.SalesTrackingCodeId4 = @SalesTrackingCodeId4, 
	TARGET.SalesTrackingCodeId5 = @SalesTrackingCodeId5
	OUTPUT INSERTED.Id INTO @LastUpdated
	;
	DROP TABLE #uniqueParameters
	
	--SELECT * from @LastUpdated

	--In the EDMX we used stored procedure mapping and this upsert is being used as the "insert". That means the EDMX is expecting an ID
	--for the 'new' row. Thus we need to figure out the ID of the row we updated if the MERGE fell into  the "Matched" clause.
	DECLARE @LastUpdatedId BIGINT = NULL
	IF EXISTS(SELECT Id FROM @LastUpdated)
	BEGIN
		SET @LastUpdatedId = (SELECT TOP 1 Id FROM @LastUpdated)
	END

	SELECT COALESCE(
			@LastUpdatedId,
			SCOPE_IDENTITY()
	) AS Id;

GO

