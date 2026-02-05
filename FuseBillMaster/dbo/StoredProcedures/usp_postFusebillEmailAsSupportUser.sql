
Create procedure [dbo].[usp_postFusebillEmailAsSupportUser]
@FusebillEmailAddress varchar(245)
as
begin

declare 
	@Email varchar(255)
	,@FirstName varchar(200)
	,@LastName varchar(200)

if right(@FusebillEmailAddress,13) ='@fusebill.com'
BEGIN
	set nocount on
	set @Email = 'fbsupport_' + @FusebillEmailAddress 
	set @FirstName = 'fbcorp\' + left(@FusebillEmailAddress,len(@FusebillEmailAddress)-13)
	set @LastName = left(@FusebillEmailAddress,len(@FusebillEmailAddress)-13)
	set @LastName = right(@LastName,Len(@lastName)-1)
	if not exists (Select * from FusebillSupportUser where ActiveDirectoryUsername = @FirstName)
	begin
	INSERT INTO [dbo].[User]
			   ([CreatedTimestamp],[ModifiedTimestamp],[Email],[FirstName],[LastName]) 
			   VALUES (GETUTCDATE(), GETUTCDATE(), @Email, @FirstName , @LastName)

	insert into FusebillSupportUser (ActiveDirectoryUsername , UserId) values (@FirstName ,SCOPE_IDENTITY())
		Print 'Agent Created'
	End
	ELSE
		Print 'Agent is already a Fusebill Support User'
	set nocount off
END
else
		Print 'Email address not recognized'
END

GO

