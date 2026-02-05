
/****** Object:  StoredProcedure [dbo].[usp_SetAccountOwner]  

Takes in
-AccountId
-UserId

Checks that there is no owner for the account already,
and assigns this user as owner if they already have an account user in the account

******/
Create PROC [dbo].[usp_SetAccountOwner]
@AccountId bigint,
@UserId bigint
AS
SET NOCOUNT ON

--Get the account user id
declare @AccountUserId bigint
set @AccountUserId = (select id from AccountUser where UserId = @UserId and AccountId = @AccountId)

--Check if the account has a current owner
declare @currentOwner bigint
set @currentOwner = (
select au.UserId from AccountUserRole aur
inner join AccountUser au on aur.AccountUserId = au.Id
where au.AccountId = @AccountId and aur.RoleId is null and aur.RoleTypeId = 1)

--if there is an owner
IF @currentOwner is not null
BEGIN
PRINT @currentOwner
PRINT 'Owner already exists for this account'
return;
END

--if account user id does not have a value
if @AccountUserId is null
BEGIN
PRINT @UserId
PRINT 'This user does not belong to the account.'
return;
END


--Then set the account user role to owner
update AccountUserRole set RoleTypeId = 1, RoleId = null where AccountUserId = @AccountUserId
PRINT 'Owner has been set'

SET NOCOUNT OFF

GO

