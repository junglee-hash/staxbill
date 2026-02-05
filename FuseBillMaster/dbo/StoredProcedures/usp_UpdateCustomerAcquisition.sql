CREATE PROC [dbo].[usp_UpdateCustomerAcquisition]

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
	UPDATE [CustomerAcquisition] SET 
		[AdContent] = @AdContent,
		[Campaign] = @Campaign,
		[Keyword] = @Keyword,
		[LandingPage] = @LandingPage,
		[Medium] = @Medium,
		[Source] = @Source,
		[CreatedTimestamp] = @CreatedTimestamp,
		[ModifiedTimestamp] = @ModifiedTimestamp,
		[SystemSource] = @SystemSource
	WHERE [Id] = @Id

SET NOCOUNT OFF

GO

