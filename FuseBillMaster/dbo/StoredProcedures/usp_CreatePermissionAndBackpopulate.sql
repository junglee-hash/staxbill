-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CreatePermissionAndBackpopulate]
	@PermissionName varchar(200),
	@ParentId int,
	@SortOrder int,
	@AllowedForSalesTrackingCode bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @NewId bigint
	SELECT @NewId = MAX(Id) + 1 
	FROM [Lookup].[Permission]

    DECLARE @MaxSortOrder int
	IF @ParentId IS NULL
		SELECT @MaxSortOrder = MAX(SortOrder)
		FROM [Lookup].[Permission]
		WHERE ParentId IS NULL
	ELSE
		SELECT @MaxSortOrder = MAX(SortOrder)
		FROM [Lookup].[Permission]
		WHERE ParentId = @ParentId

	-- Bump sort order if this permission is going in the middle
	IF @MaxSortOrder > @SortOrder
	BEGIN
		IF @ParentId IS NULL
		BEGIN
			UPDATE [Lookup].[Permission]
				SET SortOrder = SortOrder + 1
			WHERE ParentId IS NULL
			AND SortOrder >= @SortOrder

			UPDATE RolePermission
				SET SortOrder = SortOrder + 1
			WHERE ParentId IS NULL
			AND SortOrder >= @SortOrder
		END
		ELSE
		BEGIN
			UPDATE [Lookup].[Permission]
				SET SortOrder = SortOrder + 1
			WHERE ParentId = @ParentId
			AND SortOrder >= @SortOrder

			UPDATE RolePermission
				SET SortOrder = SortOrder + 1
			WHERE ParentId = @ParentId
			AND SortOrder >= @SortOrder
		END
	END

	INSERT INTO [Lookup].[Permission]
			   ([Id]
			   ,[Name]
			   ,[ParentId]
			   ,[SortOrder])
		 VALUES
			   (@NewId
			   ,@PermissionName
			   ,@ParentId
			   ,@SortOrder)

	IF @ParentId IS NULL
	BEGIN
		-- Insert new parent as always allowed
		INSERT INTO RolePermission
		(RoleId,PermissionId, ParentId, SortOrder, Allowed)
		SELECT 
		rp.RoleId,
		 @NewId,
		 @ParentId,
		 @SortOrder,
		 1
		FROM RolePermission rp
		GROUP BY rp.RoleId
	END
	ELSE
	BEGIN
		-- Back populate with the same allowed permission as the parent
		INSERT INTO RolePermission
		(RoleId,PermissionId, ParentId, SortOrder, Allowed)
		SELECT 
		rp.RoleId,
		 @NewId,
		 @ParentId,
		 @SortOrder,
		 rp.Allowed
		FROM RolePermission rp
		WHERE rp.PermissionId = @ParentId
	END

	UPDATE rp
		SET rp.Allowed = @AllowedForSalesTrackingCode
	FROM RolePermission rp
	INNER JOIN [Role] r ON r.Id = rp.RoleId AND r.LockedToSalesTrackingCode = 1
	AND rp.PermissionId = @NewId

	PRINT 'New permission created'
END

GO

