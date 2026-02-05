
CREATE PROCEDURE [dbo].[usp_UpsertNetsuiteErrorLogs]
	@netsuiteErrorLogs AS dbo.NetsuiteErrorLogList READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE ns SET
		ns.LastErrorReason = input.LastErrorReason
		, ns.ModifiedTimestamp = input.ModifiedTimestamp
		, ns.NetsuiteErrorReasonId = input.NetsuiteErrorReasonId
	FROM NetsuiteErrorLog ns
	INNER JOIN @netsuiteErrorLogs input ON ns.EntityId = input.EntityId
		AND ns.EntityTypeId = input.EntityTypeId
		AND ns.AccountId = input.AccountId

	INSERT INTO NetsuiteErrorLog ([EntityTypeId], [EntityId], [NetsuiteErrorReasonId], [LastErrorReason], [CreatedTimestamp], [ModifiedTimestamp], [AccountId])
	SELECT input.EntityTypeId, input.EntityId, input.NetsuiteErrorReasonId, input.LastErrorReason, input.CreatedTimestamp, input.ModifiedTimestamp, input.AccountId
	FROM @netsuiteErrorLogs input
	LEFT JOIN NetsuiteErrorLog ns ON ns.EntityId = input.EntityId
		AND ns.EntityTypeId = input.EntityTypeId
		AND ns.AccountId = input.AccountId
	WHERE ns.Id IS NULL

  END

GO

