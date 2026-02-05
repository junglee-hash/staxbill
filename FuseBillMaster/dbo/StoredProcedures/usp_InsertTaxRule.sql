 
 
CREATE PROC [dbo].[usp_InsertTaxRule]

	@AccountId bigint,
	@Percentage decimal,
	@Name nvarchar(60),
	@Description nvarchar(250),
	@CountryId bigint,
	@StateId bigint,
	@RegistrationCode nvarchar(100),
	@CreatedTimestamp datetime,
	@StartDate datetime,
	@EndDate datetime
AS
SET NOCOUNT ON
	INSERT INTO [TaxRule] (
		[AccountId],
		[Percentage],
		[Name],
		[Description],
		[CountryId],
		[StateId],
		[RegistrationCode],
		[CreatedTimestamp],
		[StartDate],
		[EndDate]
	)
	VALUES (
		@AccountId,
		@Percentage,
		@Name,
		@Description,
		@CountryId,
		@StateId,
		@RegistrationCode,
		@CreatedTimestamp,
		@StartDate,
		@EndDate
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

