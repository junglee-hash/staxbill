CREATE   PROCEDURE [dbo].[usp_InsertAccount]
	@CreatedTimestamp as datetime, 
	@ModifiedTimestamp as datetime, 
	@ContactEmail as nvarchar(255) = null, 
	@CompanyName as nvarchar(255) = null, 
	@FusebillTest as bit = null, 
	@Signed as bit = null, 
	@Live as bit = null, 
	@PublicApiKey as varchar(255), 
	@OriginUrlForPublicApiKey as nvarchar(4000) = null,
	@Type as tinyint = null,
	@LiveTimestamp as datetime = null,
	@AccountServiceProvider as tinyint,
	@IncludeInAutomatedProcesses as bit,
	@ProcessEarningRegardless as bit,
	@ShutdownDate as datetime,
	@ShutdownReason as nvarchar(1000),
	@ShutdownUser nvarchar(255)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO ACCOUNT (
		CreatedTimestamp
		, ModifiedTimestamp
		, ContactEmail
		, CompanyName
		, FusebillTest
		, Signed
		, Live
		, PublicApiKey
		, OriginUrlForPublicApiKey
		, TypeId
		, LiveTimestamp
		, AccountServiceProviderId
		, IncludeInAutomatedProcesses
		, ProcessEarningRegardless
		, ShutdownDate
		, ShutdownReason
		, ShutdownUser
	) VALUES (
		@CreatedTimestamp
		, @ModifiedTimestamp
		, @ContactEmail
		, @CompanyName
		, @FusebillTest
		, @Signed
		, @Live
		, @PublicApiKey
		, @OriginUrlForPublicApiKey
		, @Type
		, @LiveTimestamp
		, @AccountServiceProvider
		, @IncludeInAutomatedProcesses
		, @ProcessEarningRegardless
		, @ShutdownDate
		, @ShutdownReason
		, @ShutdownUser
	)
	
	SELECT @@IDENTITY as Id
END

GO

