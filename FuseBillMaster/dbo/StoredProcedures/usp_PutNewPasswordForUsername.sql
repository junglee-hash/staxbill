
/*********************************************************************************
[]


Inputs:
@UserName nvarchar(255),
@NewPassword nvarchar (255)

Work:
Creates random password if required
Hashes Password using Salt

Outputs:
Existing username
new password


*********************************************************************************/
Create procedure [dbo].[usp_PutNewPasswordForUsername]
@UserName nvarchar(255),
@NewPassword nvarchar (255)
AS
BEGIN TRY
set nocount on


if @NewPassword = '' or @NewPassword is null
	set @NewPassword = LEFT((convert(varchar (40),newid())),8)
Declare 
	@Salt nvarchar(60)
	,@UserId bigint

Select 
	@Salt  = Salt
	,@UserId = UserId   
from 
	[Credential]
where 
	Username  = @UserName

if @Salt is not null
begin
	declare 
		@Raw varchar (150)
		,@Hashed varchar (200)

	set @Raw = @NewPassword + @Salt 

	set @Hashed =(convert(varchar (2000), (Select HASHBYTES('md5',@Raw)),2))

	Update [Credential] 
	set 
		Password = @Hashed
	Where 
		UserId = @UserId 

	Select @UserName as UserName, @NewPassword as Password
end


SET NOCOUNT OFF
RETURN 0
END TRY

BEGIN CATCH
    IF XACT_STATE() <> 0   ROLLBACK TRANSACTION;
Return 1
END CATCH
SET NOCOUNT OFF

GO

