USE [DBQS]
GO
/****** Object:  StoredProcedure [dbo].[spCat_Countries_Languages_CRUD_Records]    Script Date: 3/23/2025 12:41:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Countries_Languages | Create - Read - Upadate - Delete 
Date:		31/12/2020
Example:
			spCat_Countries_Languages_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'AG' , @pvIdLanguage = 'DUT', @pbStatus = 1, @pbDefaultTranslation = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Languages_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX' , @pvIdLanguage = 'LMX' 
			spCat_Countries_Languages_CRUD_Records @pvOptionCRUD = 'U', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'AG' , @pvIdLanguage = 'ANG', @pbStatus = 1, @pbDefaultTranslation = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Languages_CRUD_Records @pvOptionCRUD = 'D', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX' , @pvIdLanguage = 'LMX', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Languages_CRUD_Records @pvOptionCRUD = 'X', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'MX' , @pvIdLanguage = 'LMX', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

			spCat_Countries_Languages_CRUD_Records @pvOptionCRUD = 'C', @pvIdLanguageUser = 'ANG', @pvIdCountry = 'US' , @pvIdLanguage = 'LUS', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Countries_Languages_CRUD_Records @pvOptionCRUD = 'R', @pvIdLanguageUser = 'ANG', @pvIdLanguageUser = 'SPA'
			spCat_Countries_Languages_CRUD_Records @pvOptionCRUD = 'R'
			SELECT * FROM Cat_Countries_Languages
*/
ALTER PROCEDURE [dbo].[spCat_Countries_Languages_CRUD_Records]
@pvOptionCRUD			Varchar(1),
@pvIdLanguageUser		Varchar(10) = 'ANG',
@pvIdCountry			Varchar(10) = '',
@pvIdLanguage			Varchar(10) = '',
@pbDefaultTranslation	Bit = 0,
@pbStatus				Bit			= '',
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	Declare @vDescOperationCRUD Varchar(50) = dbo.fnGetOperationCRUD(@pvOptionCRUD)

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog	Numeric
	DECLARE @vDescription	Varchar(255)	= 'Cat_Countries_Languages - ' + @vDescOperationCRUD 
	DECLARE @bSuccessful	Bit				= 1	
	DECLARE @vMessageType	Varchar(30)		= dbo.fnGetTransacMessages('OK',@pvIdLanguageUser)	--success
	DECLARE @vMessage		Varchar(Max)	= dbo.fnGetTransacMessages(@vDescOperationCRUD,@pvIdLanguageUser)
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Countries_Languages_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdLanguageUser =  '" + ISNULL(@pvIdLanguageUser,'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvIdLanguage = '" + ISNULL(@pvIdLanguage,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Countries_Languages WHERE Id_Country = @pvIdCountry and Id_Language = @pvIdLanguage)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= dbo.fnGetTransacMessages('Duplicate Record',@pvIdLanguageUser)
		END		
		ELSE -- Don´t Exists
		BEGIN
			-- Validate there is a Defaulf record
			IF @pbDefaultTranslation = 1 and EXISTS(SELECT * FROM Cat_Countries_Languages WHERE Id_Country = @pvIdCountry and Default_Translation = 1)
			BEGIN
				SET @bSuccessful	= 0
				SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
				SET @vMessage		= 'There is already a record with the default value set to true'
			END
			ELSE -- Don´t 
			BEGIN
				INSERT INTO Cat_Countries_Languages(
					Id_Country,
					Id_Language,
					Default_Translation,
					[Status],
					Modify_Date,
					Modify_By,
					Modify_IP)
				VALUES (
					@pvIdCountry,
					@pvIdLanguage,
					@pbDefaultTranslation,
					@pbStatus,
					GETDATE(),
					@pvUser,
					@pvIP)
			END
		END
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
		CL.Id_Country,
		Country_Desc = C.Short_Desc,
		CL.Id_Language,
		Language_Desc = L.Short_Desc,
		Default_Translation = ISNULL(CL.Default_Translation,0),
		CL.[Status],
		CL.Modify_Date,
		CL.Modify_By,
		CL.Modify_IP
		FROM Cat_Countries_Languages CL WITH(NOLOCK)
		
		INNER JOIN Cat_Countries C WITH(NOLOCK) ON 
		CL.Id_Country = C.Id_Country
		
		INNER JOIN Cat_Languages L WITH(NOLOCK) ON 
		CL.Id_Language = L.Id_Language AND
		L.Id_Language_Translation = @pvIdLanguageUser
		
		WHERE (@pvIdCountry = ''  OR CL.Id_Country = @pvIdCountry ) AND
		(@pvIdLanguage = '' OR CL.Id_Language = @pvIdLanguage) 
		ORDER BY CL.Id_Country, CL.Id_Language DESC -- Q+SO029 Reordenar Language (AEG 9/4/24)
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
	-- Validate there is a Defaulf record
		IF @pbDefaultTranslation = 1 and EXISTS(SELECT * FROM Cat_Countries_Languages WHERE Id_Country = @pvIdCountry and Id_Language <> @pvIdLanguage and Default_Translation = 1)
		BEGIN
			SET @bSuccessful	= 0
			SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
			SET @vMessage		= 'There is already a record with the default value set to true'
		END
		ELSE
		BEGIN
			UPDATE Cat_Countries_Languages 
			SET [Status]			= @pbStatus,
				Default_Translation = @pbDefaultTranslation,
				Modify_Date			= GETDATE(),
				Modify_By			= @pvUser,
				Modify_IP			= @pvIP
			WHERE Id_Country = @pvIdCountry AND Id_Language = @pvIdLanguage
		 END 
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN
		SET @bSuccessful	= 0
		SET @vMessageType	= dbo.fnGetTransacMessages('WAR',@pvIdLanguageUser)	--Warning
		SET @vMessage		= dbo.fnGetTransacMessages('N/A',@pvIdLanguageUser)
	END

	--------------------------------------------------------------------
	--Register Transaction Log
	--------------------------------------------------------------------
	EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription	= @vDescription, 
												@pvExecCommand	= @vExecCommand,
												@pbSuccessful	= @bSuccessful, 
												@pvMessagetType = @vMessageType,
												@pvMessage		= @vMessage, 
												@pvUser			= @pvUser, 
												@pnIdTransacLog	= @nIdTransacLog OUTPUT
	SET NOCOUNT OFF

	IF @pvOptionCRUD <> 'R'
	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog

END TRY
BEGIN CATCH
	--------------------------------------------------------------------
	-- Exception Handling
	--------------------------------------------------------------------
	SET @vMessageType	= dbo.fnGetTransacMessages('ERR',@pvIdLanguageUser)	--Error
	SET @vMessage		= dbo.fnGetTransacErrorBD()
	SET @bSuccessful	= 0 --Execution with errors
	EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription	= @vDescription, 
												@pvExecCommand	= @vExecCommand,
												@pbSuccessful	= @bSuccessful, 
												@pvMessagetType = @vMessageType,
												@pvMessage		= @vMessage, 
												@pvUser			= @pvUser, 
												@pnIdTransacLog	= @nIdTransacLog OUTPUT

	SET @vMessage		= dbo.fnGetTransacMessages('Generic Error',@pvIdLanguageUser)
	SET NOCOUNT OFF

	SELECT  Successful = @bSuccessful , MessageType = @vMessageType, Message = @vMessage, IdTransacLog = @nIdTransacLog
		
END CATCH
