
CREATE PROCEDURE [dbo].[usp_ExternalApiLog_Insert]
	@LogType TINYINT,
	@AccountId BIGINT = NULL,
	@Input NVARCHAR(4000),
	@Output NVARCHAR(4000) = NULL,
	@Message NVARCHAR(200) = NULL,
	@InternalEntityId BIGINT,
	@InternalEntityType INT,
	@ExternalEntityId NVARCHAR(50) = NULL,
	@ExternalEntityType NVARCHAR(50) = NULL,
	@CreatedTimestamp DATETIME
AS

INSERT INTO ExternalApiLog (
	[LogType],
	[AccountId],
	[Input],
	[Output],
	[Message],
	[InternalEntityId],
	[InternalEntityType],
	[ExternalEntityId],
	[ExternalEntityType],
	[CreatedTimestamp]
) VALUES (
	@LogType,
	@AccountId,
	@Input,
	@Output,
	@Message,
	@InternalEntityId,
	@InternalEntityType,
	@ExternalEntityId,
	@ExternalEntityType,
	@CreatedTimestamp
)

GO

