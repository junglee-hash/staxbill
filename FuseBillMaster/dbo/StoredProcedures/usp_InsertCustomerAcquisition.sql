 
 
CREATE PROC [dbo].[usp_InsertCustomerAcquisition]

	@Id bigint,
	@AdContent varchar(255),
	@Campaign varchar(255),
	@Keyword varchar(255),
	@LandingPage varchar(255),
	@Medium varchar(255),
	@Source varchar(255),
	@CreatedTimestamp datetime,
	@ModifiedTimestamp datetime,
	@SystemSource varchar(255)
AS
SET NOCOUNT ON
	INSERT INTO [CustomerAcquisition] (
		[Id],
		[AdContent],
		[Campaign],
		[Keyword],
		[LandingPage],
		[Medium],
		[Source],
		[CreatedTimestamp],
		[ModifiedTimestamp],
		[SystemSource]
	)
	VALUES (
		@Id,
		@AdContent,
		@Campaign,
		@Keyword,
		@LandingPage,
		@Medium,
		@Source,
		@CreatedTimestamp,
		@ModifiedTimestamp,
		@SystemSource
	)
	SELECT SCOPE_IDENTITY() As InsertedID
SET NOCOUNT OFF

GO

