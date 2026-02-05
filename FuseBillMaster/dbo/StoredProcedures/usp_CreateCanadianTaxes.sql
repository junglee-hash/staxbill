CREATE PROCEDURE [dbo].[usp_CreateCanadianTaxes]
	@AccountId BIGINT
	,@RegistrationCode VARCHAR(255) 
	,@IncludePST BIT 
AS


INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.05,'GST','',124
           ,1 -- Alberta
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.05,'GST','',124
           ,2 -- British Columbia
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

IF (@IncludePST = 1)
BEGIN
	INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.07,'PST','',124
           ,2 -- British Columbia
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

END

INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.05,'GST','',124
           ,3 -- Manitoba
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

IF (@IncludePST = 1)
BEGIN
	INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.08,'PST','',124
           ,3 -- Manitoba
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

END

INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.15,'HST','',124
           ,4 -- New Brunswick
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.15,'HST','',124
           ,5 -- New Brunswick
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.05,'GST','',124
           ,6 -- Northwest Territories
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.15,'HST','',124
           ,7 -- Nova Scotia
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.05,'GST','',124
           ,8 -- Nunavut
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.13,'HST','',124
           ,9 --Ontario
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)
           

INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.14,'HST','',124
           ,10 --PEI
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.05,'GST','',124
           ,11 -- Quebec
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

IF (@IncludePST = 1)
BEGIN
	INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.09975,'PST','',124
           ,11 -- Quebec
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

END

INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.05,'GST','',124
           ,12 -- Saskatchewan
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

IF (@IncludePST = 1)
BEGIN
	INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.05,'PST','',124
           ,12 -- Saskatchewan
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

END

INSERT INTO [dbo].[TaxRule]
           ([AccountId],[Percentage],[Name],[Description],[CountryId],[StateId],[RegistrationCode],[CreatedTimestamp],[StartDate],[EndDate],[QuickBooksTaxCodeId],[QuickBooksTaxRateId])
     VALUES
           (@AccountId,0.05,'GST','',124
           ,13 -- Yukon
           ,@RegistrationCode,GETUTCDATE(),GETUTCDATE(),NULL,NULL,NULL)

GO

