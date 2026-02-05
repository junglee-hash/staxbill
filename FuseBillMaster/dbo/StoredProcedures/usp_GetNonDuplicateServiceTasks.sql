CREATE PROCEDURE [dbo].[usp_GetNonDuplicateServiceTasks]
	@AccountId bigint,
	@JobTypeId int,
	@EntityTypeId int,
	@EntityIds varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    declare @entites table
	(
		EntityId bigint
		, ParentEntityId bigint
	)

	INSERT INTO @entites (EntityId, ParentEntityId)
	SELECT 
		(SELECT Data FROM dbo.Split(Result.Data, '-') WHERE Id = 1 ) as EntityId
		, (SELECT Data FROM dbo.Split(Result.Data, '-') WHERE Id = 2 ) as ParentEntityId
	FROM (
		SELECT Data
		FROM dbo.Split(@EntityIds, '|')
	) as Result

	SELECT DISTINCT e.*
	FROM @entites e
	LEFT JOIN ServiceTask st ON e.EntityId = st.EntityId
		AND st.StatusId = 1
		AND st.EntityTypeId = @EntityTypeId
	LEFT JOIN ServiceJob sj ON sj.Id = st.JobId
		AND sj.AccountId = @AccountId
		AND sj.TypeId = @JobTypeId
	WHERE st.Id IS NULL OR sj.Id IS NULL
	OPTION (RECOMPILE)
END

GO

