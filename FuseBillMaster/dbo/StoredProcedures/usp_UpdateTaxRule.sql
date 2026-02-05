
CREATE     PROC [dbo].[usp_UpdateTaxRule]
	@Id BIGINT
	,@AccountId BIGINT
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
SET NOCOUNT ON
	UPDATE [TaxRule] SET 
		[AccountId] = @AccountId,
		[Percentage] = @Percentage,
		[Name] = @Name,
		[Description] = @Description,
		[CountryId] = @CountryId,
		[StateId] = @StateId,
		[RegistrationCode] = @RegistrationCode,
		[CreatedTimestamp] = @CreatedTimestamp,
		[StartDate] = @StartDate,
		[EndDate] = @EndDate,
		QuickBooksTaxCodeId = @QuickBooksTaxCodeId,
		QuickBooksTaxRateId = @QuickBooksTaxRateId,
		TaxCode = @TaxCode,
		IsRetired = @IsRetired,
		AuditStatusId = @AuditStatusId,
		SalesTrackingCodeId1 = @SalesTrackingCodeId1,
		SalesTrackingCodeId2 = @SalesTrackingCodeId2,
		SalesTrackingCodeId3 = @SalesTrackingCodeId3,
		SalesTrackingCodeId4 = @SalesTrackingCodeId4,
		SalesTrackingCodeId5 = @SalesTrackingCodeId5
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

