CREATE PROC [dbo].[usp_InsertAccountPreference]

	@Id bigint,
	@TimezoneId bigint,
	@MinPasswordLength int,
	@MaxFailedLogins int,
	@ModifiedTimestamp datetime,
	@MfaRequired BIT,
	@MfaTrustPeriod int
AS
SET NOCOUNT ON
	INSERT INTO [AccountPreference] (
		[Id],
		[TimezoneId],
		[MinPasswordLength],
		[MaxFailedLogins],
		[ModifiedTimestamp],
		[MfaRequired],
		[MfaTrustPeriod]
	)
	VALUES (
		@Id,
		@TimezoneId,
		@MinPasswordLength,
		@MaxFailedLogins,
		@ModifiedTimestamp,
		@MfaRequired,
		@MfaTrustPeriod
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

