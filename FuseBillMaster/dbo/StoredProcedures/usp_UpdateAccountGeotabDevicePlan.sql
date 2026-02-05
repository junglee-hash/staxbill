

CREATE     PROCEDURE [dbo].[usp_UpdateAccountGeotabDevicePlan]
	@AccountId BIGINT,
	@Name NVARCHAR(255),
	@Id BIGINT
AS
BEGIN

	UPDATE dbo.AccountGeotabDevicePlan
	SET [name] = @Name
	WHERE AccountId = @AccountId
	AND Id = @Id

END

GO

