CREATE PROC [dbo].[usp_UpdateAccountPreference]

	@Id bigint,
	@TimezoneId bigint,
	@MinPasswordLength int,
	@MaxFailedLogins int,
	@ModifiedTimestamp datetime,
	@MfaRequired BIT,
	@MfaTrustPeriod int
AS
SET NOCOUNT ON
	UPDATE [AccountPreference] SET 
		[TimezoneId] = @TimezoneId,
		[MinPasswordLength] = @MinPasswordLength,
		[MaxFailedLogins] = @MaxFailedLogins,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[MfaRequired] = @MfaRequired,
		[MfaTrustPeriod] = @MfaTrustPeriod
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

