CREATE   PROCEDURE [dbo].[usp_UpdateAccount]
	@Id as bigint, 
	@ModifiedTimestamp as datetime, 
	@ContactEmail as nvarchar(255) = null, 
	@CompanyName as nvarchar(255) = null, 
	@FusebillTest as bit = null, 
	@Signed as bit = null, 
	@Live as bit = null, 
	@FusebillIncId as bigint = null, 
	@Note as varchar(250) = null, 
	@PublicApiKey as varchar(255), 
	@OriginUrlForPublicApiKey as nvarchar(4000) = null,
	@LiveTimestamp as datetime = null,
	@DeletedTimestamp as datetime = null,
	@DeletedBy as nvarchar(255) = null,
	@IncludeInAutomatedProcesses as bit,
	@ProcessEarningRegardless as bit,
	@ShutdownDate as datetime,
	@ShutdownReason as nvarchar(1000),
	@ShutdownUser nvarchar(255)
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE Account SET
		ModifiedTimestamp = @ModifiedTimestamp,
		ContactEmail = @ContactEmail,
		CompanyName = @CompanyName,
		FusebillTest = @FusebillTest,
		FusebillIncId = @FusebillIncId,
		Note = @Note,
		Signed = @Signed,
		Live = @Live,
		PublicApiKey = @PublicApiKey,
		OriginUrlForPublicApiKey = @OriginUrlForPublicApiKey,
		LiveTimestamp = @LiveTimestamp,
		DeletedTimestamp = @DeletedTimestamp,
		DeletedBy = @DeletedBy,
		IncludeInAutomatedProcesses = @IncludeInAutomatedProcesses,
		ProcessEarningRegardless = @ProcessEarningRegardless,
		ShutdownDate = @ShutdownDate,
		ShutdownReason = @ShutdownReason,
		ShutdownUser = @ShutdownUser
	WHERE Id = @Id
END

GO

